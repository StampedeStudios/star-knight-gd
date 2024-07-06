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
## Maximum number of bullets in the ammunition
@export_range(20, 30) var magazine_size: int = 20
## Reload time in seconds
@export_range(0.1, 2) var reload_time: float = 1.0
## Health
@export var max_health = 100
## Sound effect to be played whenever hero shoots.
const HERO_SHOOT_SFX = preload ("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const BULLET: PackedScene = preload ("res://scenes/entities/Bullet.tscn")
@onready var hud = $HUD

var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var timer: Timer

var ammunition: int = magazine_size
var is_reloading: bool = false

var health: int = max_health:
	set(damage):
		var new_value: int = health - damage
		if (new_value <= 0):
			new_value = 0
		elif (new_value > max_health):
			new_value = max_health
		health = new_value
## Shooting action to be handled by the Game Manager.
signal shoot(bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream)
signal death()
signal quit

func _ready():
	hud.update_ammo_count(ammunition, magazine_size)
	hud.update_health(health, max_health)
	timer = Timer.new()
	add_child(timer)
	timer.connect(Literals.Signals.TIMEOUT, func(): can_shoot=true)

func _process(_delta):
	if can_shoot and ammunition != 0 and !is_reloading:
		if Input.is_action_pressed(Literals.Inputs.SHOOT):
			_shoot()

func _physics_process(delta):
	player_movement(delta)

func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.is_action_pressed(Literals.Inputs.RELOAD) and !is_reloading:
			_reload()
		elif event.is_action_pressed(Literals.Inputs.QUIT):
			quit.emit()

## Handles player movement.
func player_movement(delta):
	input = _get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)
	move_and_slide()

func _shoot():
	shoot.emit(BULLET, rotation, position, HERO_SHOOT_SFX)
	ammunition = ammunition - 1
	hud.update_ammo_count(ammunition, magazine_size)
	can_shoot = false
	if ammunition != 0:
		timer.start(1 / rate_of_fire)

func _reload():
	is_reloading = true
	await get_tree().create_timer(1.0).timeout
	ammunition = magazine_size
	hud.update_ammo_count(ammunition, magazine_size)
	is_reloading = false

## Handles the health of the hero upon collision
func get_hurt(damage: int):
	health = damage
	if (health<=0):
		death.emit()
		self.queue_free()
	hud.update_health(health, max_health)

## Handles normalization of player input.
func _get_input():
	input.x = (
		int(Input.is_action_pressed(Literals.Inputs.MOVE_RIGHT))
		- int(Input.is_action_pressed(Literals.Inputs.MOVE_LEFT))
	)
	input.y = (
		int(Input.is_action_pressed(Literals.Inputs.MOVE_DOWN))
		- int(Input.is_action_pressed(Literals.Inputs.MOVE_UP))
	)
	return input.normalized()
