extends Area2D

@export var enemy_type: Enums.EnemyType = Enums.EnemyType.SHIP
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

const ENEMY_REWARD: PackedScene = preload("res://scenes/enemy/Rewards.tscn")
const BULLET: PackedScene = preload("res://scenes/enemy/EnemyBullet.tscn")
const ENEMY_SHOOT_SFX = preload("res://assets/audio/enemy_shoot.wav")


class Animations:
	const IDLE := "idle"
	const DEATH := "death"


signal death(enemy_name: String, enemy_pos: Vector2)

var _enemy_stats = StaticData.enemy_data[Enums.EnemyType.keys()[enemy_type]]
var _health: int
var _velocity: int
var _can_shoot: bool = true
var _burst: int
var _rate: float
var _ammo_count: int

var direction: Vector2 = Vector2.DOWN


func init(steps: Array):
	print(steps)
	pass


func _ready():
	animated_sprite_2d.animation = Animations.IDLE
	animated_sprite_2d.play()
	_health = _enemy_stats[Literals.EnemyStats.MAX_HEALTH]
	_velocity = _enemy_stats[Literals.EnemyStats.SPEED]
	_burst = _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.AMMO_BURST]
	_rate = 60 / _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.FIRE_RATE]
	_ammo_count = _burst


func _physics_process(_delta):
	# position += Vector2.DOWN * 35 * delta
	if _can_shoot:
		var space_state = get_world_2d().direct_space_state
		var start = self.global_position
		var end = start + Vector2.DOWN * 1000
		var query = PhysicsRayQueryParameters2D.create(start, end)
		var result = space_state.intersect_ray(query)

		if result and result.collider is Hero:
			_shoot()


func get_hurt(damage: int):
	_health -= damage
	if _health <= 0:
		_on_enemy_death()


func _on_enemy_death():
	collision_shape_2d.set_deferred("disabled", true)
	call_deferred("_spawn_reward")
	SceneManager.on_enemy_death()
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play(Animations.DEATH)


func _on_body_entered(body):
	if body.has_method("get_hurt"):
		# Deal damage to the hero
		body.get_hurt(_enemy_stats[Literals.EnemyStats.IMPACT_DAMAGE])
		# Deal max damage to self
		get_hurt(_enemy_stats[Literals.EnemyStats.MAX_HEALTH])


func _on_animated_sprite_2d_animation_finished():
	self.queue_free()


func _shoot():
	_can_shoot = false
	var spawned_bullet = BULLET.instantiate()
	get_parent().add_child(spawned_bullet)
	spawned_bullet.rotation = rotation
	spawned_bullet.position = position
	SoundManager.play_sound_effect_random_pitch(ENEMY_SHOOT_SFX)

	if _burst > 0:
		_ammo_count -= 1
		if _ammo_count > 0:
			await get_tree().create_timer(_rate, false).timeout
		else:
			_ammo_count = _burst
			await get_tree().create_timer(_rate * _burst, false).timeout
	else:
		await get_tree().create_timer(_rate, false).timeout

	_can_shoot = true


func _spawn_reward():
	var reward = ENEMY_REWARD.instantiate()
	get_parent().add_child(reward)
	reward.position = position
	reward.init_reward(Enums.EnemyType.keys()[enemy_type])
