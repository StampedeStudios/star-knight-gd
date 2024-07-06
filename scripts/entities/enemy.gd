extends Area2D

## Damage dealth to other entities
@export var damage_to_entities: int = 20

## Enemy max health
@export var max_health: int = 100

## Enemy current health 
var health: int = max_health:
	set(damage):
		var new_value: int = health - damage
		if (new_value <= 0):
			new_value = 0
		elif (new_value > max_health):
			new_value = max_health
		health = new_value

signal death()

func get_hurt(damage: int):
	health = damage;
	if(health <= 0):
		death.emit()
		self.queue_free()

func _on_body_entered(body):
	## TODO Check for potential errors (ensure we hit a body with get_hurt() function)
	body.get_hurt(damage_to_entities)
	self.queue_free()

