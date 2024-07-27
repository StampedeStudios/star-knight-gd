extends CanvasLayer

## Signal that handles all death screen events.
signal control_triggered(event: Enums.MenuEvent)
@onready var score_label := %ScoreLabel


func init(score: int) -> void:
	score_label.text = "Score: [color=red]%d[/color]" % score


## Signal emitted when [code]quit_btn[/code] is pressed from death screen.
##
## This function simply propagate the signal to be handled by upper parent which is typically
## the [code]User Interface[/code].
func _on_quit_btn_pressed() -> void:
	control_triggered.emit(Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED)


## Signal emitted when [code]restart_btn[/code] is pressed from death screen.
##
## This function simply propagate the signal to be handled by upper parent which is typically
## the [code]User Interface[/code].
func _on_restart_btn_pressed() -> void:
	control_triggered.emit(Enums.MenuEvent.RESTART_BTN_PRESSED)
