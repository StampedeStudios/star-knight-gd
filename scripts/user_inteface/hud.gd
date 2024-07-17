extends CanvasLayer

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var points: Label = %Points

var points_amount: int = 0


func update_score(amount: int):
	points_amount += amount
	points.text = "%s" % [points_amount]


func update_health(health: int, max_health: int):
	progress_bar.max_value = max_health
	progress_bar.value = health
