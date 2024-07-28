class_name Fleet
extends Area2D

const EnemyShip: PackedScene = preload("res://scenes/enemy/Enemy.tscn")
const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3
const MIN_DISTANCE = 5

var _slot_size: Vector2
var _patrol_area_position: Vector2
var _long_side: float
var _short_side: float
var _velocity: float
var _direction: Vector2


func _ready() -> void:
	var viewport: Vector2 = get_viewport().size
	_long_side = viewport.x
	_short_side = viewport.y / NUM_SPAWN_ROWS
	_slot_size = Vector2(_long_side / NUM_SPAWN_COLUMNS, _short_side / NUM_SPAWN_ROWS)
	_patrol_area_position = Vector2(viewport.x / 2, _short_side / 2)

	_velocity = 400  # TODO: Fix magic number
	_direction = (_patrol_area_position - position).normalized()


func init(units: Array[Array]) -> void:
	print("[Fleet] - Initializing %d units in the fleet" % units.size())
	for index in range(0, units.size()):
		var enemy := EnemyShip.instantiate()
		var enemy_steps: Array = units[index]

		enemy.position = _get_ship_position(enemy_steps[0])
		enemy.steps = _get_ship_step_positions(enemy_steps)

		add_child(enemy)


func _process(delta: float) -> void:
	if position.distance_to(_patrol_area_position) > MIN_DISTANCE:
		position += _direction * _velocity * delta
	else:
		set_process(false)
		_enable_ships_movement()


func _get_ship_position(piece_index: int) -> Vector2:
	# Piece position coordinates
	var side_x: float = _slot_size.x * (piece_index % NUM_SPAWN_COLUMNS) - _long_side / 2
	var side_y: float = _slot_size.y * int(piece_index / float(NUM_SPAWN_COLUMNS)) - _short_side / 2

	var pos_x: float = side_x + _slot_size.x / 2
	var pos_y: float = side_y + _slot_size.y / 2
	return Vector2(pos_x, pos_y)


func _enable_ships_movement() -> void:
	for child in get_children():
		if child is Enemy:
			child.enable()


func _get_ship_step_positions(enemy_steps: Array) -> Array:
	var positions := Array()

	for step: int in enemy_steps:
		positions.append(_get_ship_position(step))

	return positions
