class_name Enemy
extends Area2D

signal death(enemy_name: String, enemy_pos: Vector2)

const EnemyRewards: PackedScene = preload("res://scenes/enemy/Rewards.tscn")
const Bullet: PackedScene = preload("res://scenes/enemy/EnemyBullet.tscn")
const EnemyShootSfx = preload("res://assets/audio/enemy_shoot.wav")
const MIN_DISTANCE = 5

@export var enemy_type: Enums.EnemyType = Enums.EnemyType.SHIP
@export var enemy_data: EnemyData

var steps: Array
var _health: int
var _velocity: int
var _burst: int
var _rate: float
var _ammo_count: int
var _can_shoot: bool = false
var _is_movement_enabled: bool = false
var _direction := Vector2.DOWN
var _target_position: Vector2
var _last_reached_position: int
var _hero: Hero

@onready var animated_sprite_2d := $AnimatedSprite2D
@onready var collision_shape_2d := $CollisionShape2D


func _ready() -> void:
	animated_sprite_2d.animation = Animations.IDLE
	animated_sprite_2d.play()
	_health = enemy_data.max_health
	_velocity = enemy_data.speed
	_burst = enemy_data.ammo_burst
	_rate = 60.0 / enemy_data.fire_rate
	_ammo_count = _burst
	_last_reached_position = 0
	_calculate_target_position()

	_hero = SceneManager.get_hero()


func _process(delta: float) -> void:
	if _is_movement_enabled:
		if _hero:
			look_at(_hero.position)
			rotation_degrees += 90
		if position.distance_to(_target_position) > MIN_DISTANCE:
			position += _direction * _velocity * delta
		else:
			_calculate_target_position()

	if _can_shoot:
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var start: Vector2 = self.global_position
		var end: Vector2 = _hero.position
		var query := PhysicsRayQueryParameters2D.create(start, end)
		var result: Dictionary = space_state.intersect_ray(query)

		if result and result.collider is Hero:
			_shoot()


func _calculate_target_position() -> void:
	if _last_reached_position == steps.size() - 1:
		_last_reached_position = 0
	else:
		_last_reached_position += 1

	if _is_movement_enabled and steps[_last_reached_position] == _target_position:
		_is_movement_enabled = false
		await get_tree().create_timer(0.5, false).timeout
		_is_movement_enabled = true

	_target_position = steps[_last_reached_position]
	_direction = (_target_position - position).normalized()


func get_hurt(damage: int) -> void:
	_health -= damage
	if _health <= 0:
		_on_enemy_death()


func _on_enemy_death() -> void:
	collision_shape_2d.set_deferred("disabled", true)
	call_deferred("_spawn_reward")
	SceneManager.on_enemy_death()
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play(Animations.DEATH)


func _on_body_entered(body: Node) -> void:
	if body.has_method("get_hurt"):
		# Deal damage to the hero
		body.get_hurt(enemy_data.impact_damage)
		# Deal max damage to self
		get_hurt(enemy_data.max_health)


func _on_animated_sprite_2d_animation_finished() -> void:
	self.queue_free()


func _shoot() -> void:
	_can_shoot = false
	var spawned_bullet := Bullet.instantiate()
	get_parent().add_child(spawned_bullet)
	spawned_bullet.rotation = rotation
	spawned_bullet.position = position
	SoundManager.play_sound_effect_random_pitch(EnemyShootSfx)

	if _burst > 0:
		_ammo_count -= 1
		if _ammo_count > 0:
			await get_tree().create_timer(0.1, false).timeout
			_shoot()
			return

		_ammo_count = _burst
		await get_tree().create_timer(_rate, false).timeout
	else:
		await get_tree().create_timer(_rate, false).timeout

	_can_shoot = true


func _spawn_reward() -> void:
	var reward := EnemyRewards.instantiate()
	get_parent().add_child(reward)
	reward.position = position
	reward.init_reward(enemy_data.rewards)


func enable() -> void:
	_is_movement_enabled = true
	_can_shoot = true


class Animations:
	const IDLE := "idle"
	const DEATH := "death"
