extends Area2D
class_name Fleet

const ENEMY_SHIP: PackedScene = preload("res://scenes/enemy/Enemy.tscn")

const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3
const MIN_DISTANCE = 5

var _enemy_stats = StaticData.enemy_data[Enums.EnemyType.keys()[Enums.EnemyType.SHIP]]

var slot_size: Vector2
var patrol_area_position: Vector2
var long_side
var short_side

var _velocity
var direction


func _ready():
	var viewport = get_viewport().size
	long_side = viewport.x
	short_side = viewport.y / NUM_SPAWN_ROWS
	slot_size = Vector2(long_side / NUM_SPAWN_COLUMNS, short_side / NUM_SPAWN_ROWS)
	patrol_area_position = Vector2(viewport.x / 2, short_side / 2)

	_velocity = _enemy_stats[Literals.EnemyStats.SPEED]
	direction = (patrol_area_position - position).normalized()


func init(units):
	print("[Fleet] - Initializing %d units in the fleet" % units.size())
	for index in range(0, units.size()):
		var enemy = ENEMY_SHIP.instantiate()
		var enemy_steps = units[String.num(index)]

		enemy.position = _get_ship_position(enemy_steps[0])
		enemy.steps = _get_ship_step_positions(enemy_steps)

		add_child(enemy)


func _process(delta):
	if position.distance_to(patrol_area_position) > MIN_DISTANCE:
		position += direction * _velocity * delta
	else:
		set_process(false)
		_enable_ships_movement()


func _get_ship_position(piece_index: int) -> Vector2:
	# Piece position coordinates
	var side_x: float = slot_size.x * (piece_index % NUM_SPAWN_COLUMNS) - long_side / 2
	var side_y: float = slot_size.y * int(piece_index / float(NUM_SPAWN_COLUMNS)) - short_side / 2

	var pos_x: float = side_x + slot_size.x / 2
	var pos_y: float = side_y + slot_size.y / 2
	return Vector2(pos_x, pos_y)


func _enable_ships_movement():
	for child in get_children():
		if child is Enemy:
			child.enable()


func _get_ship_step_positions(enemy_steps: Array) -> Array:
	var positions := Array()

	for step in enemy_steps:
		positions.append(_get_ship_position(step))

	return positions
