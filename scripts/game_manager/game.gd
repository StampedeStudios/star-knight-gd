extends Node2D

@onready var texture_rect = $TextureRect

var time = 0


func _process(delta):
	time += delta
	texture_rect.material.set_shader_parameter("time", time)
