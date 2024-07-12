extends CanvasLayer
## Handle all functionalities and events triggered by the Menu Canvas.

@onready var start_btn = $BtnContainer/StartBtn
@onready var quit_btn = $BtnContainer/QuitBtn

## Signal that handles all menu events.
signal control_triggered(event: Enums.MenuEvent)

var quick_menu: bool = false


## Signal emitted when [code]start_btn[/code] is pressed.
##
## This function simply propagate the signal to be handled by upper parent which is typically the [code]User Interface[/code].
func _on_start_btn_pressed():
	if quick_menu:
		control_triggered.emit(Enums.MenuEvent.CONTINUE_BTN_PRESSED)
	else:
		control_triggered.emit(Enums.MenuEvent.START_BTN_PRESSED)


## Signal emitted when [code]how_to_play_btn[/code] is pressed.
##
## This function simply propagate the signal to be handled by upper parent which is typically the [code]User Interface[/code].
func _on_how_to_play_btn_pressed():
	control_triggered.emit(Enums.MenuEvent.HOW_TO_PLAY_BTN_PRESSED)


## Signal emitted when [code]quit[/code] is pressed.
func _on_quit_btn_pressed():
	if quick_menu:
		control_triggered.emit(Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED)
	else:
		control_triggered.emit(Enums.MenuEvent.QUIT_BTN_PRESSED)


func set_quick_menu(is_quick_menu: bool):
	quick_menu = is_quick_menu

	if quick_menu:
		start_btn.text = "CONTINUE"
	else:
		start_btn.text = "START"
