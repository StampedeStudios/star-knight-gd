extends CharacterBody2D
class_name Hero
## Script that handles the logic of the player described as `Hero`.
##
## Movement, shooting and health of player are handled by this script.

## Maximum speed that should be reachable by the hero.
@export var max_speed: float = 800
## Default acceleration of the hero ship.
@export var accel: float = 8000
## Default friction of the hero ship.
@export var friction: float = 3000
## Number of bullets that player is able too shoot within a second.
@export_range(1, 10) var rate_of_fire: float = 240
## Health
@export var max_health = 100
## Sound effect to be played whenever hero shoots.
const HERO_SHOOT_SFX = preload("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const BULLET: PackedScene = preload("res://scenes/hero/Bullet.tscn")
@onready var hud = $HUD
@onready var animated_sprite_2d = $AnimatedSprite2D

var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true
var health: int = max_health

var timer : Timer


class Animations:
	const IDLE := "idle"
	const ACCELERATING := "accelerating"
	const CRUISING := "cruising"


## Shooting action to be handled by the Game Manager.
signal death
signal quit


func _ready():
	animated_sprite_2d.animation = Animations.IDLE
	hud.update_health(health, max_health)
	rate_of_fire = 60 / rate_of_fire
	timer = Timer.new()
	add_child(timer)


func _process(_delta):
	if Input.is_action_pressed(Literals.Inputs.SHOOT) and can_shoot:
		_shoot()


func _physics_process(delta):
	player_movement(delta)


func _unhandled_key_input(event):
	if event is InputEventKey:
		if event.is_action_pressed(Literals.Inputs.QUIT):
			quit.emit()


## Handles player movement.
func player_movement(delta):
	input = _get_input()
	if input.y < 0:
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
	var bullet = BULLET.instantiate()
	bullet.position = position
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	SoundManager.play_sound_effect_random_pitch(HERO_SHOOT_SFX)
	can_shoot = false
	timer.start(rate_of_fire)
	await timer.timeout
	can_shoot = true


## Handles the health of the hero upon collision
func get_hurt(damage: int):
	health -= damage
	if health <= 0:
		death.emit()
		self.queue_free()
	hud.update_health(health, max_health)


func get_heal(heal: int):
	health += heal
	hud.update_health(health, max_health)
	while health > max_health:
		await get_tree().create_timer(1.0, false).timeout
		health -= 1
		hud.update_health(health, max_health)


func update_score(amount: int):
	hud.update_score(amount)


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
