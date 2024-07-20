extends Area2D
## Default bullet
##
## Basic bullet entity, part of the basic hero weapons.

## Bullet velocity
@export var _velocity = 2000

## Bullet damage to entities
@export var damage = 51

## Animated Sprite Node Reference
@export var animated_sprite_2d: AnimatedSprite2D


class Animations:
	const MOVING := "moving"
	const HIT := "hit"


var rng = RandomNumberGenerator.new()
var random_explosion_rotation: float
var random_explosion_position_x: float
var random_explosion_position_y: float
var random_position_treshold: float = 10.0


func _ready():
	if animated_sprite_2d:
		animated_sprite_2d.animation = Animations.MOVING
		animated_sprite_2d.play()


func _physics_process(delta):
	position += -self.transform.y * _velocity * delta


func _on_area_entered(area):
	if area.has_method("get_hurt"):
		area.get_hurt(damage)

	call_deferred("_remove_bullet")


func _randomize_bullet_sprite():
	random_explosion_rotation = rng.randf_range(0, 2 * PI)
	random_explosion_position_x = rng.randf_range(
		-random_position_treshold, random_position_treshold
	)
	random_explosion_position_y = rng.randf_range(
		-random_position_treshold, random_position_treshold
	)
	rotation = rad_to_deg(random_explosion_rotation)
	position = Vector2(
		position.x + random_explosion_position_x, position.y + random_explosion_position_y
	)


func _on_body_entered(body):
	if body.has_method("get_hurt"):
		body.get_hurt(damage)

	call_deferred("_remove_bullet")


func _remove_bullet():
	if animated_sprite_2d:
		$CollisionShape2D.disabled = true
		_randomize_bullet_sprite()
		animated_sprite_2d.animation = Animations.HIT
		_velocity = Vector2.ZERO
	else:
		queue_free()


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == Animations.HIT:
		queue_free()
