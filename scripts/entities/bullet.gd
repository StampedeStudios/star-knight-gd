extends Area2D

var velocity = Vector2.UP * 1000

func _physics_process(delta):
  position += velocity * delta