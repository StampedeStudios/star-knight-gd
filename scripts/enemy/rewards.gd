extends Area2D

@export var pickup_sound : AudioStream
var reward_choiced : String

## Called to decide the type of Pickupable based on the type of enemy 
func init_reward(enemy_name:String):
	if StaticData.enemy_data.has(enemy_name):
		if StaticData.enemy_data[enemy_name].has(Literals.EnemyStats.REWARD):			
			var rewards = StaticData.enemy_data[enemy_name][Literals.EnemyStats.REWARD]
			var choice = randf_range(0,1)
			var sum : float = 0
			for reward in rewards:
				sum += StaticData.enemy_data[enemy_name][Literals.EnemyStats.REWARD][reward]
				if choice <= sum :
					reward_choiced = reward
					break
			if !reward_choiced:
				self.queue_free()
		else:
			push_error("'%s' del '%s' non trovato nel JSON" %[Literals.EnemyStats.REWARD,enemy_name])
	else:
		push_error("'%s' non trovato nel JSON" %[enemy_name])


func _on_body_entered(body):
	if body is Hero:
		match reward_choiced:
			Literals.EnemyRewards.LIFE:
				_on_health_gained(body)
			_:
				push_error("'%s' non gestita")
		self.queue_free()

func _on_health_gained(hero:Hero):
	SoundManager.play_sound_effect(pickup_sound)
	hero.get_heal(Literals.EnemyRewards.LIFE_AMOUNT)