extends Node2D

var time: float = 0

@onready var texture_rect := $TextureRect


func _process(delta: float) -> void:
	time += delta
	texture_rect.material.set_shader_parameter("time", time)
