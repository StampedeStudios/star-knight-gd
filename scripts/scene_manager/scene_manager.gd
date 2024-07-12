extends Node
## The [code]Scene Manager[/code] is the handler of every level, enemy and hero spawn.
##
## Every logic that involve levels should be handled here.

## Hero is always needed, hence preloaded.
var hero = preload("res://scenes/hero/Hero.tscn")
var nemesis = preload("res://scenes/enemy/Nemesis.tscn")

## Levels handling
var reached_level: int = 0
var hero_instance: Node
var nemesis_instance: Node
var current_level: Node
var levels = []
var score: int = 0

const BOTTOM_POSITION_OFFSET: int = 150
const LEVELS_FOLDER_PATH: String = "res://levels"
var viewport_size: Vector2


func init(saved_reached_level: int):
	reached_level = saved_reached_level
	# Refreshing viewport size to handle windows resizing
	viewport_size = get_viewport().size

	var levels_directory: DirAccess = DirAccess.open(LEVELS_FOLDER_PATH)
	if levels_directory:
		levels_directory.list_dir_begin()

		var level_name: String = levels_directory.get_next()
		while level_name != "":
			levels.append(LEVELS_FOLDER_PATH + "//" + level_name)
			level_name = levels_directory.get_next()
		print("[Scene Manager] Found following levels: %s" % str(levels))
	else:
		push_error("No levels found in directory %s" % LEVELS_FOLDER_PATH)


func load_next_level():
	get_tree().paused = false

	if not hero_instance:
		print("[Scene Manager] Hero not found, instantiating a new one")
		hero_instance = hero.instantiate()
		add_child(hero_instance)

		# Set position to bottom center
		hero_instance.position = Vector2(
			viewport_size.x / 2, viewport_size.y - BOTTOM_POSITION_OFFSET
		)

		hero_instance.connect(Literals.Signals.SHOOT, _on_hero_shoot)
		hero_instance.connect(Literals.Signals.QUIT_REQUEST, _on_quit_request)
		hero_instance.connect(Literals.Signals.DEATH, _on_hero_death)

	print("[Scene Manager] Loading level: %s" % reached_level)
	var level = load(levels[reached_level])
	if not level:
		push_error("Fatal error, level not loaded")
		return

	current_level = level.instantiate()
	add_child(current_level)

	if not nemesis_instance:
		print("[Scene Manager] Nemesis not found, instantiating a new one")
		nemesis_instance = nemesis.instantiate()
		add_child(nemesis_instance)

	nemesis_instance.clean_restart(current_level.level_name, current_level.waves)


## Handles the bullet spawning process when [code]hero[/code] is shooting.
func _on_hero_shoot(
	bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream
):
	var spawned_bullet = bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
	SoundManager.play_sound_effect_random_pitch(audio_clip)


func _on_quit_request():
	get_tree().paused = true
	UserInterface.pop_quick_menu()


func unstop():
	get_tree().paused = false


func _on_enemies_defeated():
	current_level.queue_free()
	reached_level = reached_level + 1

	if reached_level >= levels.size():
		_finish_game()
	else:
		load_next_level()


func _on_hero_death():
	UserInterface.pop_death_screen(score)
	clean_scene()
	print_debug("GAME OVER")


func on_enemy_death():
	score += 1
	hero_instance.update_score(1)


func _finish_game():
	print("GG!")  # TODO: Handle end game


func clean_scene():
	# Resetting score
	score = 0
	if is_instance_valid(nemesis_instance):
		nemesis_instance.reset()
		nemesis_instance.queue_free()

	for child in get_children():
		child.queue_free()


func restart():
	clean_scene()
	reached_level = 0
	load_next_level()
