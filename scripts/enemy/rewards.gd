extends Area2D

@export var pickup_sound: AudioStream
var reward_choiced: String


## Called to decide the type of Pickupable based on the type of enemy
func init_reward(enemy_name: String) -> void:
	if StaticData.enemy_data.has(enemy_name):
		if StaticData.enemy_data[enemy_name].has(Literals.EnemyStats.REWARD):
			var rewards: Dictionary = StaticData.enemy_data[enemy_name][Literals.EnemyStats.REWARD]
			var choice: float = randf_range(0, 1)
			var sum: float = 0
			for reward: String in rewards:
				sum += StaticData.enemy_data[enemy_name][Literals.EnemyStats.REWARD][reward]
				if choice <= sum:
					reward_choiced = reward
					break
			if !reward_choiced:
				self.queue_free()
		else:
			push_error("'%s' '%s' not found in JSON" % [enemy_name, Literals.EnemyStats.REWARD])
	else:
		push_error("'%s' not found in JSON" % [enemy_name])


func _process(delta: float) -> void:
	position += Vector2.DOWN * 150 * delta


func _on_body_entered(body: Node) -> void:
	if body is Hero:
		match reward_choiced:
			Literals.EnemyRewards.LIFE:
				_on_health_gained(body)
			_:
				push_error("'%s' not handled")
		self.queue_free()


func _on_health_gained(hero: Hero) -> void:
	SoundManager.play_sound_effect(pickup_sound)
	hero.get_heal(Literals.EnemyRewards.LIFE_AMOUNT)
