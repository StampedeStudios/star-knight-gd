extends Node
## The [code]Scene Manager[/code] is the handler of every wave, enemy and hero spawn.
##
## Every logic that involve waves should be handled here.

const BOTTOM_POSITION_OFFSET: int = 150

## Hero is always needed, hence preloaded.
var HeroScene: PackedScene = preload("res://scenes/hero/Hero.tscn")
var Nemesis: PackedScene = preload("res://scenes/enemy/Nemesis.tscn")

var _reached_wave: int = 0
var _hero_instance: Node
var _nemesis_instance: Node
var _score: int = 0
var _viewport_size: Vector2


func init(saved_reached_wave: int) -> void:
	_reached_wave = saved_reached_wave

	# Refreshing viewport size to handle windows resizing
	_viewport_size = get_viewport().size


func start_waves() -> void:
	get_tree().paused = false

	if not _hero_instance:
		print("[Scene Manager] Hero not found, instantiating a new one")
		_hero_instance = HeroScene.instantiate()
		add_child(_hero_instance)

		# Set position to bottom center
		_viewport_size = get_viewport().size
		_hero_instance.position = Vector2(
			_viewport_size.x / 2, _viewport_size.y - BOTTOM_POSITION_OFFSET
		)

		_hero_instance.connect(Literals.Signals.QUIT_REQUEST, _on_quit_request)
		_hero_instance.connect(Literals.Signals.DEATH, _on_hero_death)

	print("[Scene Manager] Starting from wave: %s" % _reached_wave)

	if not _nemesis_instance:
		print("[Scene Manager] Nemesis not found, instantiating a new one")
		_nemesis_instance = Nemesis.instantiate()
		add_child(_nemesis_instance)

	_nemesis_instance.clean_restart()


func _on_quit_request() -> void:
	get_tree().paused = true
	UserInterface.pop_quick_menu()


func unstop() -> void:
	get_tree().paused = false


func _on_hero_death() -> void:
	UserInterface.pop_death_screen(_score)
	clean_scene()
	print_debug("GAME OVER")


func on_enemy_death() -> void:
	_score += 1
	_hero_instance.update_score(1)


func clean_scene() -> void:
	# Resetting score
	_score = 0
	if is_instance_valid(_nemesis_instance):
		_nemesis_instance.reset()
		_nemesis_instance.queue_free()

	for child in get_children():
		child.queue_free()


func restart() -> void:
	clean_scene()
	_reached_wave = 0
	start_waves()


func get_hero() -> Hero:
	return _hero_instance
