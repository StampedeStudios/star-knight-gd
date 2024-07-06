extends CanvasLayer

@onready var ammo_count: Label = %AmmoCount
@onready var progress_bar: ProgressBar = %ProgressBar


func update_ammo_count(ammunition: int, magazine_size: int):
	ammo_count.text = "%s/%s" % [ammunition, magazine_size]

func update_health(health: int, max_health: int):
	progress_bar.max_value = max_health
	progress_bar.value = health
