extends Node
## The [code]Nemesis[/code] is the enemy entity that handles all attacks directed to the hero.
##
## Every logic that involve enemy attacks will be handled here.

const ENEMY_SHIP: PackedScene = preload("res://scenes/enemy/Enemy.tscn")
const ENEMY_REWARD: PackedScene = preload("res://scenes/enemy/Rewards.tscn")

var level_name: String
var enemies_left: int
var waves: Array

var viewport: Vector2


func clean_restart(l_name: String, wave_info: Array):
	level_name = l_name
	waves = wave_info

	_start_wave(0)


## Setup wave to start spawning enemies.
func _start_wave(index: int):
	if waves.size() == 0:
		push_warning("No waves found in %s" % level_name)
		pass

	var delay: int = 3
	await get_tree().create_timer(delay, false).timeout
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
	viewport = get_viewport().size
	var enemies: int = 5
	var interval_x: int = int(viewport.x / enemies)
	var interval_y: int = 200

	for index in range(0, num_enemies):
		var random_waiting_time: int = randi_range(1, 5)
		await get_tree().create_timer(random_waiting_time, false).timeout
		var enemy = ENEMY_SHIP.instantiate()

		var next_position_x: int = (index % (enemies - 1)) + 1
		if index == enemies - 1:
			interval_y += 200
		var x_position = next_position_x * interval_x
		enemy.position = Vector2(x_position, interval_y)
		enemy.connect(Literals.Signals.DEATH, _on_enemy_death)
		enemy.connect(Literals.Signals.SHOOT, _on_enemy_shoot)
		add_child(enemy)
	pass


func _on_enemy_death(enemy_name: String, enemy_pos: Vector2):
	var reward = ENEMY_REWARD.instantiate()
	reward.position = enemy_pos
	reward.init_reward(enemy_name)
	call_deferred("add_child", reward)
	SceneManager.on_enemy_death()

	enemies_left = enemies_left - 1
	if enemies_left == 0:
		SceneManager._on_enemies_defeated()


func _on_enemy_shoot(
	bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream
):
	var spawned_bullet = bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	SoundManager.play_sound_effect_random_pitch(audio_clip)


func reset():
	for child in get_children():
		child.queue_free()
