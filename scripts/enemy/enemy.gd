extends Area2D

@export var enemy_type : Enums.EnemyType = Enums.EnemyType.SHIP

signal death(enemy_name:String, enemy_pos:Vector2)

var _enemy_stats =StaticData.enemy_data[Enums.EnemyType.keys()[enemy_type]]

## Enemy current health 
var _health: int

func _ready():
	_health=_enemy_stats[Literals.EnemyStats.MAX_HEALTH]

func get_hurt(damage: int):
	_health -= damage;
	if(_health <= 0):
		var enemy_name = Enums.EnemyType.keys()[enemy_type]
		death.emit(enemy_name, self.position)
		self.queue_free()

func _on_body_entered(body):
	if body.has_method("get_hurt"):
		body.get_hurt(_enemy_stats [Literals.EnemyStats.IMPACT_DAMAGE])
		self.queue_free()
