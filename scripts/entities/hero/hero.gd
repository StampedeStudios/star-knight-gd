extends Node2D
## Script that handles the logic of the player described as `Hero`.
##
## Movement, shooting and health of player are handled by this script.

@onready var entity = $Entity

## Maximum speed that should be reachable by the hero.
@export_range(40, 1000) var max_speed: float = 400
## Default acceleration of the hero ship.
@export_range(1000, 5000) var accel: float = 3000
## Default friction of the hero ship.
@export_range(1000, 5000) var friction: float = 1500
## Number of bullets that player is able too shoot within a second.
@export_range(1, 10) var rate_of_fire: float = 10

## Sound effect to be played whenever hero shoots.
const HERO_SHOOT_SFX = preload ("res://assets/audio/hero_shoot.wav")
## Default hero bullet type.
const BULLET: PackedScene = preload ("res://scenes/entities/Bullet.tscn")

var input: Vector2 = Vector2.ZERO
var can_shoot: bool = true;
var timer: Timer

## Shooting action to be handled by the Game Manager.
signal shoot(bullet, direction, location)
signal quit()

func _ready():
    timer = Timer.new()
    add_child(timer)
    timer.connect(Literals.Signals.TIMEOUT, func(): can_shoot=true)

func _process(_delta):
    if (can_shoot):
        if (Input.is_action_pressed(Literals.Inputs.SHOOT)):
            shoot.emit(BULLET, entity.rotation, entity.position, HERO_SHOOT_SFX)
            can_shoot = false
            timer.start(1 / rate_of_fire)
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
        if (entity.velocity.length() > (friction * delta)):
            entity.velocity -= entity.velocity.normalized() * (friction * delta)
        else:
            entity.velocity = Vector2.ZERO;
    else:
        entity.velocity += (input * accel * delta)
        entity.velocity = entity.velocity.limit_length(max_speed)
    entity.move_and_slide()
