extends Node

@export var area_limit: CollisionShape2D
@export var left: CollisionShape2D
@export var right: CollisionShape2D
@export var top: CollisionShape2D
@export var bottom: CollisionShape2D


func _ready():
	get_viewport().size_changed.connect(_on_viewport_change)


func _on_viewport_change():
	var pos = get_viewport().size
	area_limit.position = pos / 2
	area_limit.scale = pos

	var top_left = Vector2.ZERO
	var top_right = Vector2(pos.x, 0)
	var bottom_left = Vector2(0, pos.y)
	var bottom_right = pos
	left.shape.a = top_left
	left.shape.b = bottom_left
	right.shape.a = top_right
	right.shape.b = bottom_right
	top.shape.a = top_left
	top.shape.b = top_right
	bottom.shape.a = bottom_left
	bottom.shape.b = bottom_right


func _on_area_limit_area_exited(area):
	area.queue_free()
