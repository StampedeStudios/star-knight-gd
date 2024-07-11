extends CharacterBody2D
class_name Hero
## Script that handles the logic of the player described as `Hero`.
##
## Movement, shooting and health of player are handled by this script.

## Maximum speed that should be reachable by the hero.
@export_range(40, 1000) var max_speed: float = 800
## Default acceleration of the hero ship.
@export_range(1000, 5000) var accel: float = 4500
## Default friction of the hero ship.
@export_range(1000, 5000) var friction: float = 3000
## Number of bullets that player is able too shoot within a second.
@export_range(1, 10) var rate_of_fire: float = 4
## Maximum number of bullets in the ammunition
@export_range(20, 30) var magazine_size: int = 22
## Reload time in seconds
@export_range(0.1, 2) var reload_time: float = 1.0
## Health
@export var max_health = 100
## Sound effect to be played whenever hero shoots.
const HERO_SHOOT_SFX = preload ("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const BULLET: PackedScene = preload ("res://scenes/hero/Bullet.tscn")
@onready var hud = $HUD
@onready var animated_sprite_2d = $AnimatedSprite2D

var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var timer: Timer

var ammunition: int = magazine_size
var is_reloading: bool = false

var health: int = max_health

class Animations:
	const IDLE := 'idle'
	const ACCELERATING := 'accelerating'
	const CRUISING := 'cruising'

## Shooting action to be handled by the Game Manager.
signal shoot(bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream)
signal death()
signal quit

func _ready():
	animated_sprite_2d.animation = Animations.IDLE
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
	if (input.y < 0):
		animated_sprite_2d.play(Animations.ACCELERATING)
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play(Animations.IDLE)
	else:
		velocity += (input * accel * delta)
		velocity = velocity.limit_length(max_speed)

	animated_sprite_2d.play()
	move_and_slide()

func _shoot():
	shoot.emit(BULLET, rotation, position, HERO_SHOOT_SFX)
	ammunition = ammunition - 1
	hud.update_ammo_count(ammunition, magazine_size)
	can_shoot = false
	if ammunition > 0:
		timer.start(1 / rate_of_fire)
	else:
		_reload()

func _reload():
	is_reloading = true
	await get_tree().create_timer(1.0).timeout
	ammunition = magazine_size
	hud.update_ammo_count(ammunition, magazine_size)
	is_reloading = false

## Handles the health of the hero upon collision
func get_hurt(damage: int):
	health -= damage
	if (health <= 0):
		death.emit()
		self.queue_free()
	hud.update_health(health, max_health)
	
func get_heal(heal: int):
	health += heal
	hud.update_health(health, max_health)
	while health > max_health:
		await get_tree().create_timer(1.0).timeout
		health -= 1
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
