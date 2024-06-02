extends CanvasLayer

## Signal that handles all How To Play section events.
signal control_triggered(event: Enums.MenuEvent)

## Signal emitted when [code]back_to_menu_btn[/code] is pressed.
##
## This function simply propagate the signal to be handled by upper parent which is typically the [code]User Interface[/code].
func _on_back_to_menu_btn_pressed():
    control_triggered.emit(Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED)
