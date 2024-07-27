class_name Hero
extends CharacterBody2D
## Script that handles the logic of the player described as `Hero`.
##
## Movement, shooting and health of player are handled by this script.

## Shooting action to be handled by the Game Manager.
signal death
signal quit

## Sound effect to be played whenever hero shoots.
const HeroShootSfx = preload("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const Bullet: PackedScene = preload("res://scenes/hero/Bullet.tscn")

## Maximum speed that should be reachable by the hero.
@export var max_speed: float = 800
## Default acceleration of the hero ship.
@export var accel: float = 8000
## Default friction of the hero ship.
@export var friction: float = 3000
## Number of bullets that player is able too shoot within a second.
@export_range(1, 10) var rate_of_fire: float = 240
## Health
@export var max_health: int = 100

var _input: Vector2 = Vector2.ZERO
var _can_shoot: bool = true
var _health: int = max_health
var _timer: Timer

@onready var hud := $HUD
@onready var animated_sprite_2d := $AnimatedSprite2D


func _ready() -> void:
	animated_sprite_2d.animation = Animations.IDLE
	hud.update_health(_health, max_health)
	rate_of_fire = 60 / rate_of_fire
	_timer = Timer.new()
	add_child(_timer)


func _process(_delta: float) -> void:
	if Input.is_action_pressed(Literals.Inputs.SHOOT) and _can_shoot:
		_shoot()


func _physics_process(delta: float) -> void:
	player_movement(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed(Literals.Inputs.QUIT):
			quit.emit()


## Handles player movement.
func player_movement(delta: float) -> void:
	_input = _get_input()
	if _input.y < 0:
		animated_sprite_2d.play(Animations.ACCELERATING)
	if _input == Vector2.ZERO:
		if velocity.length() > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
			animated_sprite_2d.play(Animations.IDLE)
	else:
		velocity += (_input * accel * delta)
		velocity = velocity.limit_length(max_speed)

	animated_sprite_2d.play()
	move_and_slide()


func _shoot() -> void:
	var bullet := Bullet.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	SoundManager.play_sound_effect_random_pitch(HeroShootSfx)
	_can_shoot = false
	_timer.start(rate_of_fire)
	await _timer.timeout
	_can_shoot = true


## Handles the health of the hero upon collision
func get_hurt(damage: int) -> void:
	_health -= damage
	if _health <= 0:
		death.emit()
		self.queue_free()
	hud.update_health(_health, max_health)


func get_heal(heal: int) -> void:
	_health += heal
	hud.update_health(_health, max_health)
	while _health > max_health:
		await get_tree().create_timer(1.0, false).timeout
		_health -= 1
		hud.update_health(_health, max_health)


func update_score(amount: int) -> void:
	hud.update_score(amount)


## Handles normalization of player input.
func _get_input() -> Vector2:
	_input.x = (
		int(Input.is_action_pressed(Literals.Inputs.MOVE_RIGHT))
		- int(Input.is_action_pressed(Literals.Inputs.MOVE_LEFT))
	)
	_input.y = (
		int(Input.is_action_pressed(Literals.Inputs.MOVE_DOWN))
		- int(Input.is_action_pressed(Literals.Inputs.MOVE_UP))
	)
	return _input.normalized()


class Animations:
	const IDLE := "idle"
	const ACCELERATING := "accelerating"
	const CRUISING := "cruising"
