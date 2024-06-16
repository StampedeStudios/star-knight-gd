extends CanvasLayer
## Handle all functionalities and events triggered by the Menu Canvas.

## Signal that handles all menu events.
signal control_triggered(event: Enums.MenuEvent)

## Signal emitted when [code]start_btn[/code] is pressed.
##
## This function simply propagate the signal to be handled by upper parent which is typically the [code]User Interface[/code].
func _on_start_btn_pressed():
    control_triggered.emit(Enums.MenuEvent.START_BTN_PRESSED)

## Signal emitted when [code]how_to_play_btn[/code] is pressed.
##
## This function simply propagate the signal to be handled by upper parent which is typically the [code]User Interface[/code].
func _on_how_to_play_btn_pressed():
    control_triggered.emit(Enums.MenuEvent.HOW_TO_PLAY_BTN_PRESSED)

## Signal emitted when [code]quit[/code] is pressed.
func _on_quit_btn_pressed():
    control_triggered.emit(Enums.MenuEvent.QUIT_BTN_PRESSED)
