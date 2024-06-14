extends Node2D
@onready var entity = $Entity

@export var max_speed: float = 400
@export var accel: float = 3000
@export var friction: float = 1500
@export var rate_of_fire: float = 10

const Bullet: PackedScene = preload ("res://scenes/entities/Bullet.tscn")
var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true;

var timer: Timer = Timer.new()
signal shoot(bullet, direction, location)

func _ready():
	add_child(timer)
	timer.connect(Literals.Signals.TIMEOUT, func(): can_shoot=true)

func _process(_delta):
	if (can_shoot):
		if (Input.is_action_pressed(Literals.Inputs.SHOOT)):
			shoot.emit(Bullet, entity.rotation, entity.position)
			can_shoot = false
			timer.start(1 / rate_of_fire)

func _physics_process(delta):
	player_movement(delta)

func get_input():
	input.x = int(Input.is_action_pressed(Literals.Inputs.MOVE_RIGHT)) - int(Input.is_action_pressed(Literals.Inputs.MOVE_LEFT))
	input.y = int(Input.is_action_pressed(Literals.Inputs.MOVE_DOWN)) - int(Input.is_action_pressed(Literals.Inputs.MOVE_UP))
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
