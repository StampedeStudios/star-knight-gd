extends CanvasLayer

@onready var ammo_count: Label = %AmmoCount

func update_ammo_count(ammunition: int, magazine_size: int):
	ammo_count.text = '%s/%s' % [ammunition, magazine_size]
