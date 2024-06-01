extends CanvasLayer

signal control_triggered(event: Enums.MenuEvent)

func _on_start_btn_pressed():
    control_triggered.emit(Enums.MenuEvent.START_BTN_PRESSED)

func _on_how_to_play_btn_pressed():
    # TODO: Handle this function
    pass # Replace with function body.
