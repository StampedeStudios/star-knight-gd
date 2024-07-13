extends Area2D
## Default bullet
## 
## Basic bullet entity, part of the basic hero weapons.

## Bullet velocity
@export var velocity := Vector2.DOWN * 300 
@export var damage = 10

	
func _physics_process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body.has_method("get_hurt"):
		body.get_hurt(damage)
		self.queue_free()
