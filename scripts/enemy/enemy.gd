extends Area2D

@export var enemy_type: Enums.EnemyType = Enums.EnemyType.SHIP
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

signal death(enemy_name: String, enemy_pos: Vector2)

var _enemy_stats = StaticData.enemy_data[Enums.EnemyType.keys()[enemy_type]]

class Animations:
	const IDLE := 'idle'
	const DEATH := 'death'

## Enemy current health 
var _health: int

func _ready():
	animated_sprite_2d.animation = Animations.IDLE
	animated_sprite_2d.play()
	_health = _enemy_stats[Literals.EnemyStats.MAX_HEALTH]

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
