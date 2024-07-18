extends Area2D
class_name Fleet

const ENEMY_SHIP: PackedScene = preload("res://scenes/enemy/Enemy.tscn")

const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3

var long_side: float
var short_side: float


func _ready():
	# Get viewport size
	var viewport = get_viewport().size

	long_side = viewport.x
	short_side = viewport.y / NUM_SPAWN_ROWS


func init(steps):
	for index in range(0, steps.size()):
		var enemy_steps = steps[String.num(index)]
		var enemy = ENEMY_SHIP.instantiate()

		enemy.position = get_ship_position(enemy_steps[0])
		# enemy.init(enemy_steps)
		add_child(enemy)


func _physics_process(delta):
	position += Vector2.DOWN * 35 * delta


func get_ship_position(piece_index: int) -> Vector2:
	var slot_size := Vector2(long_side / NUM_SPAWN_COLUMNS, short_side / NUM_SPAWN_ROWS)

	# Piece position coordinates
	var side_x := slot_size.x * (piece_index % NUM_SPAWN_COLUMNS)
	var side_y := slot_size.y * int(piece_index / float(NUM_SPAWN_COLUMNS))

	var pos_x := side_x + slot_size.x / 2
	var pos_y := side_y + slot_size.y / 2
	return Vector2(pos_x, pos_y)
