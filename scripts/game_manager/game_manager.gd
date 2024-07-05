extends Node
## The [code]Game Manager[/code] is the handler of the game loop.
##
## Every logic which require cooperation between different systems should be handled here to respect the principle "call down signal up".

## User Interface reference.
@onready var user_interface = $UserInterface
## Sound Manager reference.
@onready var sound_manager = $SoundManager
## Scene Manager reference.
@onready var scene_manager = $SceneManager


func _ready():
	# TODO: load saved data to fetch reached level index
	scene_manager.init(0)


## Handles all UI signals/events triggered from [code]User Interface[/code].
##
## Handles all UI events which require game logic centrilized in the [code]Game Manager[/code] such as:[br]- Load Level;[br]- Save Level;[br]- Pause Game.
func _on_user_interface_event_initiated(event: Enums.GameEvent):
	match event:
		Enums.GameEvent.STARTED:
			scene_manager.load_next_level()
			user_interface.hide_all()
			pass
		Enums.GameEvent.QUIT:
			get_tree().quit()
			pass
		_:
			pass


func _on_scene_manager_quit():
	user_interface.pop_menu()


## Redirect all UI sounds to the Sound manager.
func _on_user_interface_sound_played(audio_clip: AudioStream):
	sound_manager.play_sound_effect(audio_clip)


## Redirect all Scene Manager sounds to the Sound manager.
func _on_scene_manager_sound_played(audio_clip: AudioStream):
	sound_manager.play_sound_effect(audio_clip)
