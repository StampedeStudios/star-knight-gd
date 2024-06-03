extends Node
## The [code]Game Manager[/code] is the handler of the game loop.
##
## Every logic which require cooperation between different systems should be handled here to respect the principle "call down signal up".

## User Interface reference.
@onready var user_interface = $UserInterface

## Handles all UI signals/events triggered from [code]User Interface[/code].
##
## Handles all UI events which require game logic centrilized in the [code]Game Manager[/code] such as:[br]- Load Level;[br]- Save Level;[br]- Pause Game.
func _on_user_interface_event_initiated(event: Enums.GameEvent):
	match event:
		Enums.GameEvent.STARTED:
			var level = load("res://levels/Level1.tscn")
			
			if not level:
				print("Error loading level")
				return

			user_interface.hide_all()
			add_child(level.instantiate())
			pass
		_:
			pass
