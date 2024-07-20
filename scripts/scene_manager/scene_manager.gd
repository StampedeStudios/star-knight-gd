extends Node
## The [code]Scene Manager[/code] is the handler of every wave, enemy and hero spawn.
##
## Every logic that involve waves should be handled here.

## Hero is always needed, hence preloaded.
var hero = preload("res://scenes/hero/Hero.tscn")
var nemesis = preload("res://scenes/enemy/Nemesis.tscn")

var reached_wave: int = 0
var hero_instance: Node
var nemesis_instance: Node
var score: int = 0

const BOTTOM_POSITION_OFFSET: int = 150
var viewport_size: Vector2


func init(saved_reached_wave: int):
	reached_wave = saved_reached_wave

	# Refreshing viewport size to handle windows resizing
	viewport_size = get_viewport().size


func start_waves():
	get_tree().paused = false

	if not hero_instance:
		print("[Scene Manager] Hero not found, instantiating a new one")
		hero_instance = hero.instantiate()
		add_child(hero_instance)

		# Set position to bottom center
		viewport_size = get_viewport().size
		hero_instance.position = Vector2(
			viewport_size.x / 2, viewport_size.y - BOTTOM_POSITION_OFFSET
		)

		hero_instance.connect(Literals.Signals.QUIT_REQUEST, _on_quit_request)
		hero_instance.connect(Literals.Signals.DEATH, _on_hero_death)

	print("[Scene Manager] Starting from wave: %s" % reached_wave)

	if not nemesis_instance:
		print("[Scene Manager] Nemesis not found, instantiating a new one")
		nemesis_instance = nemesis.instantiate()
		add_child(nemesis_instance)

	nemesis_instance.clean_restart()


func _on_quit_request():
	get_tree().paused = true
	UserInterface.pop_quick_menu()


func unstop():
	get_tree().paused = false


func _on_hero_death():
	UserInterface.pop_death_screen(score)
	clean_scene()
	print_debug("GAME OVER")


func on_enemy_death():
	score += 1
	hero_instance.update_score(1)


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
	reached_wave = 0
	start_waves()
