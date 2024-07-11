extends Area2D

@export var enemy_type: Enums.EnemyType = Enums.EnemyType.SHIP
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

class Animations:
	const IDLE := 'idle'
	const DEATH := 'death'

const BULLET: PackedScene = preload ("res://scenes/enemy/EnemyBullet.tscn")
const HERO_SHOOT_SFX = preload ("res://assets/audio/hero_shoot.wav")

signal death(enemy_name:String, enemy_pos:Vector2)
signal shoot(bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream)

var _enemy_stats =StaticData.enemy_data[Enums.EnemyType.keys()[enemy_type]]
var _health: int
var _velocity : int
var _can_shoot : bool = true
var _burst : int
var _rate : float
var _ammo_count : int

func _ready():
	animated_sprite_2d.animation = Animations.IDLE
	animated_sprite_2d.play()
	_health = _enemy_stats[Literals.EnemyStats.MAX_HEALTH]
	_velocity = _enemy_stats[Literals.EnemyStats.SPEED] 
	_burst = _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.AMMO_BURST]
	_rate = _enemy_stats[Literals.EnemyStats.GUN][Literals.EnemyGun.FIRE_RATE]
	_ammo_count = _burst	
	
func _physics_process(delta):
	position += Vector2.DOWN * _velocity * delta
	
	if _can_shoot:
		var space_state = get_world_2d().direct_space_state
		var start = self.position
		var end = start + Vector2.DOWN*1000
		var query = PhysicsRayQueryParameters2D.create(start, end)
		var result = space_state.intersect_ray(query)
		if  result and result.collider is Hero: 
			_shoot()

func get_hurt(damage: int):
	_health -= damage;
	if (_health <= 0):
		collision_shape_2d.set_deferred("disabled", true)
		var enemy_name = Enums.EnemyType.keys()[enemy_type]
		death.emit(enemy_name, self.position)
		animated_sprite_2d.play(Animations.DEATH)

func _on_body_entered(body):
	if body.has_method("get_hurt"):
		body.get_hurt(_enemy_stats[Literals.EnemyStats.IMPACT_DAMAGE])
		self.queue_free()

func _on_animated_sprite_2d_animation_finished():
		animated_sprite_2d.animation = Animations.DEATH
		self.queue_free()

func _shoot():
	_can_shoot = false
	shoot.emit(BULLET, rotation, position, HERO_SHOOT_SFX)	
	
	if _burst>0:
		_ammo_count -= 1
		if _ammo_count >0:
			await get_tree().create_timer(_rate).timeout
		else:
			_ammo_count = _burst
			await get_tree().create_timer(_rate * _burst).timeout
	else:
		await get_tree().create_timer(_rate).timeout
				
	_can_shoot = true
