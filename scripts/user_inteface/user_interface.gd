extends Control

signal event_initiated(event: Enums.UIEvent)

func _on_menu_control_triggered(event: Enums.MenuEvent):
    # TODO: Handle preloading of level (e.g. hide menu, stop music etc.)
    match event:
        Enums.MenuEvent.START_BTN_PRESSED:
            event_initiated.emit(Enums.UIEvent.GAME_STARTED)
        _:
            pass
