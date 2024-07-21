extends Area2D
class_name Enemy

@export var enemy_type: Enums.EnemyType = Enums.EnemyType.SHIP
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

const ENEMY_REWARD: PackedScene = preload("res://scenes/enemy/Rewards.tscn")
const BULLET: PackedScene = preload("res://scenes/enemy/EnemyBullet.tscn")
const ENEMY_SHOOT_SFX = preload("res://assets/audio/enemy_shoot.wav")
const MIN_DISTANCE = 5


class Animations:
	const IDLE := "idle"
	const DEATH := "death"


signal death(enemy_name: String, enemy_pos: Vector2)

var _enemy_stats = StaticData.enemy_data[Enums.EnemyType.keys()[enemy_type]]
var _health: int
var _velocity: int
var _burst: int
var _rate: float
var _ammo_count: int
var _can_shoot: bool = false
var _is_movement_enabled: bool = false

var _direction: Vector2 = Vector2.DOWN
var steps: Array
var _target_position: Vector2
var _last_reached_position: int

var hero: Hero


func _ready():
	animated_sprite_2d.animation = Animations.IDLE
	animated_sprite_2d.play()
	_health = _enemy_stats[Literals.EnemyStats.MAX_HEALTH]
	_velocity = _enemy_stats[Literals.EnemyStats.SPEED]
	_burst = _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.AMMO_BURST]
	_rate = 60 / _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.FIRE_RATE]
	_ammo_count = _burst
	_last_reached_position = 0
	_calculate_target_position()

	hero = SceneManager.get_hero()


func _process(delta):
	if _is_movement_enabled:
		if hero:
			look_at(hero.position)
			rotation_degrees += 90
		if position.distance_to(_target_position) > MIN_DISTANCE:
			position += _direction * _velocity * delta
		else:
			_calculate_target_position()

	if _can_shoot:
		var space_state = get_world_2d().direct_space_state
		var start = self.global_position
		var end = hero.position
		var query = PhysicsRayQueryParameters2D.create(start, end)
		var result = space_state.intersect_ray(query)

		if result and result.collider is Hero:
			_shoot()


func _calculate_target_position():
	if _last_reached_position == steps.size() - 1:
		_last_reached_position = 0
	else:
		_last_reached_position += 1

	if _is_movement_enabled and steps[_last_reached_position] == _target_position:
		_is_movement_enabled = false
		await get_tree().create_timer(0.5, false).timeout
		_is_movement_enabled = true

	_target_position = steps[_last_reached_position]
	_direction = (_target_position - position).normalized()


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
			await get_tree().create_timer(0.1, false).timeout
			_shoot()
			return
		else:
			_ammo_count = _burst
			await get_tree().create_timer(_rate, false).timeout
	else:
		await get_tree().create_timer(_rate, false).timeout

	_can_shoot = true


func _spawn_reward():
	var reward = ENEMY_REWARD.instantiate()
	get_parent().add_child(reward)
	reward.position = position
	reward.init_reward(Enums.EnemyType.keys()[enemy_type])


func enable():
	_is_movement_enabled = true
	_can_shoot = true
