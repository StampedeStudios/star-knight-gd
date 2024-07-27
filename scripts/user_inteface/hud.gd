extends CanvasLayer

var points_amount: int = 0

@onready var progress_bar := %ProgressBar
@onready var points := %Points


func update_score(amount: int) -> void:
	points_amount += amount
	points.text = "%s" % [points_amount]


func update_health(health: int, max_health: int) -> void:
	progress_bar.max_value = max_health
	progress_bar.value = health
