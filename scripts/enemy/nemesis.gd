extends Node
## The [code]Nemesis[/code] is the enemy entity that handles all attacks directed to the hero.
##
## Every logic that involve enemy attacks will be handled here.

const EnemyShip: PackedScene = preload("res://scenes/enemy/Enemy.tscn")
const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3
const MAX_SHIPS_AMOUNT := 8

@export var formations: Array[FormationData]

var waves: Array
var _num_ships_left: int
var _long_side: float
var _short_side: float
var _slot_size: Vector2
var _patrol_area_position: Vector2


func _ready() -> void:
	var viewport: Vector2 = get_viewport().size
	_long_side = viewport.x
	_short_side = viewport.y / NUM_SPAWN_ROWS
	_slot_size = Vector2(_long_side / NUM_SPAWN_COLUMNS, _short_side / NUM_SPAWN_ROWS)
	_patrol_area_position = Vector2(viewport.x / 2, _short_side / 2)


func clean_restart() -> void:
	# Starting to spawn enemies
	_start_wave(0)


## Setup wave to start spawning enemies.
func _start_wave(index: int) -> void:
	const START_DELAY: int = 1  # TODO: Set dynamic delay
	await get_tree().create_timer(START_DELAY, false).timeout

	# Pick random formation with given odds
	var steps: Array[Array] = select_random_formation()

	print("[Nemesis] Wave %s spawning" % [index + 1])
	await _spawn_enemy(steps)

	_start_wave(index + 1)


## Handles the spawn of enemies.
func _spawn_enemy(steps: Array[Array]) -> void:
	var enemy := EnemyShip.instantiate()
	enemy.position = _get_spawn_position()
	enemy.steps = _get_ship_step_positions(steps[0])
	enemy.enable()

	add_child(enemy)

	const START_DELAY: int = 1
	await get_tree().create_timer(START_DELAY, false).timeout


func reset() -> void:
	for child in get_children():
		child.queue_free()


func select_random_formation() -> Array[Array]:
	var choice: float = randf_range(0, 1)
	var sum: float = 0
	for formation: FormationData in formations:
		sum += formation.odds
		if choice <= sum:
			return formation.unit_position

	push_error("No waves select, the total odds does not adds up to 100%")
	return []


func _get_ship_position(piece_index: int) -> Vector2:
	# Piece position coordinates
	var side_x: float = _slot_size.x * (piece_index % NUM_SPAWN_COLUMNS)
	var side_y: float = _slot_size.y * int(piece_index / float(NUM_SPAWN_COLUMNS))

	var pos_x: float = side_x + _slot_size.x / 2
	var pos_y: float = side_y + _slot_size.y / 2
	return Vector2(pos_x, pos_y)


func _get_ship_step_positions(enemy_steps: Array) -> Array:
	var positions := Array()

	for step: int in enemy_steps:
		positions.append(_get_ship_position(step))

	return positions


## TODO: Docs
func _get_spawn_position() -> Vector2:
	var spawn_pos := Vector2(0, 0)
	var spawn_perimeter: float = _long_side + _short_side * 2

	# Random point on perimeter
	var random_point: float = randf_range(0, spawn_perimeter)

	if random_point < _short_side:
		# The spawning point is on the left side
		spawn_pos = Vector2(0, random_point - _short_side)
	elif random_point < _long_side + _short_side:
		# The spawning point is on the top side
		spawn_pos = Vector2(random_point - _short_side, 0)
	else:
		# The spawning point is on the right side
		spawn_pos = Vector2(_long_side, -_short_side + random_point - _long_side)

	return spawn_pos
