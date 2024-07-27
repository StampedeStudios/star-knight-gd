extends Node

const ENEMY_DATA_PATH := "res://assets/json_data/json_enemy_data.json"
const WAVE_DATA_PATH := "res://assets/json_data/json_wave_data.json"

var enemy_data: Dictionary = {}
var wave_data: Dictionary = {}


func _ready() -> void:
	enemy_data = load_json_file(ENEMY_DATA_PATH)
	wave_data = load_json_file(WAVE_DATA_PATH)


func load_json_file(file_path: String) -> Dictionary:
	if FileAccess.file_exists(file_path):
		var data := FileAccess.open(file_path, FileAccess.READ)
		var parse: Dictionary = JSON.parse_string(data.get_as_text())

		if parse is Dictionary:
			return parse
		push_error("File: %s can't be converted" % [file_path])

	push_error("File: %s doesn't exist" % [file_path])
	return {}
