extends Node
## The [code]Nemesis[/code] is the enemy entity that handles all attacks directed to the hero.
##
## Every logic that involve enemy attacks will be handled here.

@export var formations: Array[Formation]

const FLEET: PackedScene = preload("res://scenes/enemy/Fleet.tscn")
const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3

var waves: Array


func clean_restart() -> void:
	# Starting to spawn enemies
	_start_wave(0)


## Setup wave to start spawning enemies.
func _start_wave(index: int) -> void:
	const START_DELAY: int = 3
	await get_tree().create_timer(START_DELAY, false).timeout

	# Pick random formation with given odds
	var steps: Array[Array] = select_random_formation()
	# Select spawn area from center, left and right
	var position: Enums.Position = randi_range(0, 2) as Enums.Position
	# Spawn an enemy in each position indicated by the array index

	print("[Nemesis] Wave %s spawning in position [%s]" % [index + 1, position])
	await _spawn_enemies(steps, position)

	_start_wave(index + 1)


## Handles the spawn of enemies.
func _spawn_enemies(steps: Array[Array], spawn_side: Enums.Position) -> void:
	var fleet: Fleet = FLEET.instantiate()
	var viewport: Vector2 = get_viewport().size
	var fleet_starting_position_y: float = viewport.y / NUM_SPAWN_ROWS / 2
	var fleet_starting_position_x: float = viewport.x / 2

	match spawn_side:
		Enums.Position.TOP:
			fleet.position = Vector2(fleet_starting_position_x, -fleet_starting_position_y)
		Enums.Position.LEFT:
			fleet.position = Vector2(-fleet_starting_position_x, fleet_starting_position_y)
		Enums.Position.RIGHT:
			fleet.position = Vector2(
				viewport.x + fleet_starting_position_x, fleet_starting_position_y
			)

	add_child(fleet)
	fleet.init(steps)

	const START_DELAY: int = 8
	await get_tree().create_timer(START_DELAY, false).timeout


func reset() -> void:
	for child in get_children():
		child.queue_free()


func select_random_formation() -> Array[Array]:
	var choice: float = randf_range(0, 1)
	var sum: float = 0
	for formation: Formation in formations:
		sum += formation.odds
		if choice <= sum:
			return formation.unit_position

	push_error("No waves select, the total odds does not adds up to 100%")
	return []
