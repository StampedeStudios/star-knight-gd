extends Node2D
@onready var entity = $Entity

@export var max_speed: float = 400
@export var accel: float = 3000
@export var friction: float = 1500

signal shoot(bullet, direction, location)
var Bullet: PackedScene = preload ("res://scenes/entities/Bullet.tscn")

var input: Vector2 = Vector2.ZERO

func _process(_delta):
	if (Input.is_action_pressed("shoot")):
		shoot.emit(Bullet, entity.rotation, entity.position)

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input.normalized()

func player_movement(delta):
	input = get_input()
	if (input == Vector2.ZERO):
		if (entity.velocity.length() > (friction * delta)):
			entity.velocity -= entity.velocity.normalized() * (friction * delta)
		else:
			entity.velocity = Vector2.ZERO;
	else:
		entity.velocity += (input * accel * delta)
		entity.velocity = entity.velocity.limit_length(max_speed)
	entity.move_and_slide()
