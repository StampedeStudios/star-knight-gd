extends Area2D

## Enemy max health
@export var max_health: int = 100

## Enemy current health 
var health: int = max_health

signal death()

func get_hurt(damage: int):
	health -= damage;
	if(health < 0):
		health = 0
		death.emit()
		self.queue_free()

func _on_area_entered(area):
	self.queue_free()
