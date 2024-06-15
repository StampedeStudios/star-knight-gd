extends Area2D
## Default bullet
## 
## Basic bullet entity, part of the basic hero weapons.

## Bullet velocity
var velocity = Vector2.UP * 1000

func _physics_process(delta):
  position += velocity * delta