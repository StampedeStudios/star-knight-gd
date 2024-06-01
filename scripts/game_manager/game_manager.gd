extends Node

func _on_user_interface_event_initiated(event: Enums.UIEvent):
    match event:
        Enums.UIEvent.GAME_STARTED:
            print_debug("Loading level")
            # TODO: Load level
            pass
        _:
            pass
