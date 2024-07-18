extends Node
## The [code]Nemesis[/code] is the enemy entity that handles all attacks directed to the hero.
##
## Every logic that involve enemy attacks will be handled here.

const FLEET: PackedScene = preload("res://scenes/enemy/Fleet.tscn")
const NUM_SPAWN_COLUMNS := 5
const NUM_SPAWN_ROWS := 3

var waves: Array

var formations = StaticData.wave_data[Literals.Waves.FORMATIONS]


func clean_restart():
	# Starting to spawn enemies
	_start_wave(0)


## Setup wave to start spawning enemies.
func _start_wave(index: int):
	# TODO: decomment
	# const START_DELAY: int = 3
	# await get_tree().create_timer(START_DELAY, false).timeout

	# Pick random formation with given odds
	var steps = select_random_formation()
	# Select spawn area from center, left and right
	var position: Enums.Position = Enums.Position.TOP
	# randi_range(0, 2) as Enums.Position
	# Spawn an enemy in each position indicated by the array index

	print("[Nemesis] Wave %s spawning in position [%s]" % [index + 1, position])
	await _spawn_enemies(steps, position)

	_start_wave(index + 1)


## Handles the spawn of enemies.
func _spawn_enemies(steps, spawn_side: Enums.Position):
	var fleet: Fleet = FLEET.instantiate()

	var viewport = get_viewport().size

	match spawn_side:
		Enums.Position.TOP:
			fleet.position = Vector2(0, -viewport.y / NUM_SPAWN_ROWS)
		Enums.Position.LEFT:
			fleet.position = Vector2(-viewport.x, 0)
		Enums.Position.RIGHT:
			fleet.position = Vector2(viewport.x, 0)

	add_child(fleet)
	fleet.init(steps)

	const START_DELAY: int = 15
	await get_tree().create_timer(START_DELAY, false).timeout


func reset():
	for child in get_children():
		child.queue_free()


func select_random_formation():
	var choice = randf_range(0, 1)
	var sum: float = 0
	for formation in formations:
		sum += formation[Literals.Waves.ODDS]
		if choice <= sum:
			return formation[Literals.Waves.STEPS]

	push_error("No waves select, the total odds does not adds up to 100%")
	return []
