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
var _long_side: float
var _short_side: float
var _slot_size: Vector2
var _patrol_area_position: Vector2
var _ships: Array[Enemy] = []


func _ready() -> void:
	var viewport: Vector2 = get_viewport().size
	_long_side = viewport.x
	_short_side = viewport.y / NUM_SPAWN_ROWS
	_slot_size = Vector2(_long_side / NUM_SPAWN_COLUMNS, _short_side / NUM_SPAWN_ROWS)
	_patrol_area_position = Vector2(viewport.x / 2, _short_side / 2)

	var steps: Array[Array] = select_random_formation(5)

	for index in range(0, 5):
		_spawn_enemy(_get_ship_step_positions(steps[index]))


func clean_restart() -> void:
	# TODO: Fix this function
	# Starting to spawn enemies
	# _start_wave()
	pass


## Setup wave to start spawning enemies.
func _refresh_formation() -> void:
	var num_ships: int = _ships.size()
	var steps: Array[Array] = select_random_formation(num_ships)
	for index in range(0, _ships.size()):
		_ships[index].init(_get_ship_step_positions(steps[index]))
	pass


func _on_enemy_death(checkpoints: Array[Vector2], instance: Enemy) -> void:
	for index in range(0, _ships.size()):
		if _ships[index] == instance:
			print("Removed a ship")
			_ships.remove_at(index)
			break

	print("Ship left: %s" % _ships.size())

	var num_new_ships: int = randi_range(0, 10)
	if num_new_ships > 3:
		_spawn_enemy(checkpoints)
	else:
		call_deferred("_refresh_formation")


## Handles the spawn of enemies.
func _spawn_enemy(checkpoints: Array[Vector2]) -> void:
	var enemy := EnemyShip.instantiate()
	enemy.position = _get_spawn_position()
	enemy.init(checkpoints)
	call_deferred("add_child", enemy)

	enemy.connect(Literals.Signals.DEATH, _on_enemy_death)
	_ships.append(enemy)


func reset() -> void:
	for child in get_children():
		child.queue_free()


func select_random_formation(num_ships: int) -> Array[Array]:
	var choice: float = randf_range(0, 1)
	var sum: float = 0

	var specific_formations: Array[FormationData] = formations.filter(
		func(f: FormationData) -> bool: return f.num_ships == num_ships
	)

	for formation: FormationData in specific_formations:
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


func _get_ship_step_positions(steps_indexes: Array) -> Array[Vector2]:
	var positions: Array[Vector2] = []

	for step: int in steps_indexes:
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
