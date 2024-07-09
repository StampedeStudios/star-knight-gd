extends Area2D
## Default bullet
##
## Basic bullet entity, part of the basic hero weapons.

## Bullet velocity
var velocity = Vector2.UP * 1000
@export var damage = 20


func _ready():
	var timer := Timer.new()
	timer.connect(Literals.Signals.TIMEOUT, queue_free)
	add_child(timer)
	timer.start(3)


func _physics_process(delta):
	position += velocity * delta


func _on_area_entered(area):
	if area.has_method("get_hurt"):
		area.get_hurt(damage)
		self.queue_free()
