class_name EnemyData
extends Resource

@export_group("Basic stats")
@export var max_health: int = 100
@export var impact_damage: int = 20
@export var speed: int = 400

## Gun related stats
@export_group("Weapon stats")
@export var fire_rate: int = 60
@export var ammo_burst: int = 3
@export var ammo_speed: int = 100
@export var ammo_damage: int = 10

## Rewards related stats
@export_group("Reward stats")
@export var rewards: Array[RewardData]
