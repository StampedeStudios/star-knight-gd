extends Area2D
class_name Fleet

const ENEMY_SHIP: PackedScene = preload("res://scenes/enemy/Enemy.tscn")

const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3

# TODO: handle different enemy fleets
var _enemy_stats = StaticData.enemy_data[Enums.EnemyType.keys()[Enums.EnemyType.SHIP]]

var slot_size: Vector2
var patrol_area_position: Vector2
var long_side
var short_side


func _ready():
	var viewport = get_viewport().size
	long_side = viewport.x
	short_side = viewport.y / NUM_SPAWN_ROWS
	slot_size = Vector2(long_side / NUM_SPAWN_COLUMNS, short_side / NUM_SPAWN_ROWS)
	patrol_area_position = Vector2(viewport.x / 2, short_side / 2)


func init(steps):
	for index in range(0, steps.size()):
		var enemy_steps = steps[String.num(index)]
		var enemy = ENEMY_SHIP.instantiate()

		enemy.position = get_ship_position(enemy_steps[0])
		# enemy.init(enemy_steps)
		add_child(enemy)


func _physics_process(delta):
	var distance: float = position.distance_to(patrol_area_position)
	var _velocity = _enemy_stats[Literals.EnemyStats.SPEED]

	if distance > 5:
		if position.x < patrol_area_position.x:
			position.x += delta * _velocity
		else:
			position.x -= delta * _velocity

		if position.y < patrol_area_position.y:
			position.y += delta * _velocity
		else:
			position.y -= delta * _velocity
		# position += Vector2.DOWN * 60 * delta


func get_ship_position(piece_index: int) -> Vector2:
	# Piece position coordinates
	var side_x: float = slot_size.x * (piece_index % NUM_SPAWN_COLUMNS) - long_side / 2
	var side_y: float = slot_size.y * int(piece_index / float(NUM_SPAWN_COLUMNS)) - short_side / 2

	var pos_x: float = side_x + slot_size.x / 2
	var pos_y: float = side_y + slot_size.y / 2
	return Vector2(pos_x, pos_y)
