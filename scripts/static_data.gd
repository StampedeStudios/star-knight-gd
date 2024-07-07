extends Node

var enemy_data ={}
var enemy_data_path = "res://assets/json_data/json_enemy_data.json"

func _ready():
	enemy_data = load_json_file(enemy_data_path)

func load_json_file(file_path:String):
	if FileAccess.file_exists(file_path):
		var data = FileAccess.open(file_path,FileAccess.READ)
		var parse = JSON.parse_string(data.get_as_text())
		
		if parse is Dictionary:
			return parse
		else:
			printerr("Il file: %s non può essere convertito" %[file_path])
	else:
		printerr("Il file: %s non esiste" %[file_path])
