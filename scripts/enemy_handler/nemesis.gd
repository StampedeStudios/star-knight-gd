extends Node
## The [code]Nemesis[/code] is the enemy entity that handles all attacks directed to the hero.
##
## Every logic that involve enemy attacks will be handled here.

const ENEMY_SHIP: PackedScene = preload ("res://scenes/entities/Enemy.tscn")

var level_name: String
var enemies_left: int
var waves: Array

# TODO delete
var viewport: Vector2
signal enemies_defetead

func reset_stats(l_name: String, wave_info: Array):
	level_name = l_name
	waves = wave_info
	_start_wave(0)

## Setup wave to start spawning enemies.
func _start_wave(index: int):
	if waves.size() == 0:
		push_warning("No waves found in %s" % level_name)
		pass

	var delay: int = 10
	await get_tree().create_timer(delay).timeout
	print("[Nemesis] Wave %s started" % [index + 1])

	var num_enemies: int = waves[index]
	await _spawn_enemies(num_enemies)

	if index + 1 >= waves.size():
		print("[Nemesis] All enemies in %s spawned" % [level_name])
	else:
		print("[Nemesis] Wave [%s/%s] surpassed" % [index + 1, waves.size()])
		_start_wave(index + 1)

## Handles the spawn of enemies.
func _spawn_enemies(num_enemies: int):
	# for index in range(0, num_enemies):
		var random_waiting_time: int = randi_range(1, 5)
		await get_tree().create_timer(random_waiting_time).timeout
		var enemy = ENEMY_SHIP.instantiate()
		viewport = get_viewport().size
		enemy.position = Vector2(viewport.x / 2, viewport.x / 2)
		enemy.connect(Literals.Signals.DEATH, _on_enemy_death)
		add_child(enemy)
	# pass

func _on_enemy_death():
	enemies_left = enemies_left - 1

	if enemies_left == 0:
		enemies_defetead.emit()
