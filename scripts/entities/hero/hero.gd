extends CharacterBody2D
## Script that handles the logic of the player described as `Hero`.
##
## Movement, shooting and health of player are handled by this script.

## Maximum speed that should be reachable by the hero.
@export_range(40, 1000) var max_speed: float = 400
## Default acceleration of the hero ship.
@export_range(1000, 5000) var accel: float = 3000
## Default friction of the hero ship.
@export_range(1000, 5000) var friction: float = 1500
## Number of bullets that player is able too shoot within a second.
@export_range(1, 10) var rate_of_fire: float = 10
## Maximum number of bullets in the magazine_size 
@export_range(20, 30) var max_magazine_size: int = 20
## Reload time in seconds
@export_range(0.1, 2) var reload_time: float = 1.0
## Sound effect to be played whenever hero shoots.
const HERO_SHOOT_SFX = preload ("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const BULLET: PackedScene = preload ("res://scenes/entities/Bullet.tscn")

var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var timer: Timer

var magazine_size: int = max_magazine_size
var is_reloading: bool = false

## Shooting action to be handled by the Game Manager.
signal shoot(bullet, direction, location)
signal quit()

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect(Literals.Signals.TIMEOUT, func(): can_shoot=true)

func _process(_delta):
	if (can_shoot&&magazine_size != 0):
		if (Input.is_action_pressed(Literals.Inputs.SHOOT)):
			_shoot()
	if (!is_reloading):
		if (Input.is_action_just_pressed(Literals.Inputs.RELOAD)):
			_reload()

	if (Input.is_action_pressed('quit')):
		quit.emit()

func _physics_process(delta):
	player_movement(delta)

## Handles normalization of player input.
func get_input():
	input.x = int(Input.is_action_pressed(Literals.Inputs.MOVE_RIGHT)) - int(Input.is_action_pressed(Literals.Inputs.MOVE_LEFT))
	input.y = int(Input.is_action_pressed(Literals.Inputs.MOVE_DOWN)) - int(Input.is_action_pressed(Literals.Inputs.MOVE_UP))
	return input.normalized()

## Handles player movement.
func player_movement(delta):
	input = get_input()
	if (input == Vector2.ZERO):
		if (velocity.length() > (friction * delta)):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	move_and_slide()

func _shoot():
	shoot.emit(BULLET, rotation, position, HERO_SHOOT_SFX)
	magazine_size = magazine_size - 1
	can_shoot = false
	if (magazine_size != 0):
		timer.start(1 / rate_of_fire)

func _reload():
	is_reloading = true
	await get_tree().create_timer(1.0).timeout
	magazine_size = max_magazine_size
	is_reloading = false