extends Node
## The [code]Sound Manager[/code] is the handler of the all sound effects and background music.

## Number of AudioStreamPlayer that will be created as starting pool to execute Sound effects.
@export_range(1, 20) var sfx_pool_size: int = 3

## Pool of SFX Audio Stream Players.
var _sfx_players: Array[AudioStreamPlayer] = []
var _rng := RandomNumberGenerator.new()

## Handles constants playing of music in a loop without interruptions.
@onready var music_player := $MusicPlayer


func _ready() -> void:
	# Initialize Pool
	for i in range(sfx_pool_size):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.volume_db = -20
		add_child(sfx_player)
		_sfx_players.append(sfx_player)


## Function that plays a sound effect whenever required applying a random pitch scale.
func play_sound_effect_random_pitch(clip: AudioStream) -> void:
	var player: AudioStreamPlayer = _get_available_sfx_player()
	player.set_stream(clip)
	player.pitch_scale = _rng.randf_range(0.8, 1.2)
	player.play()


## Function that consent a sound effect to be played whenever required.
func play_sound_effect(clip: AudioStream) -> void:
	var player: AudioStreamPlayer = _get_available_sfx_player()
	player.set_stream(clip)
	player.play()


## Provide a free SFX player
##
## Loop through all player to fetch one that is not already playing a sound effect.
## If no player are available it creates a new one and add it to the pool.
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player

	push_warning(
		"All AudioStreamPlayer are busy, adding a new one to the pool: {%s}" % _sfx_players.size()
	)
	var new_player := AudioStreamPlayer.new()
	new_player.volume_db = -20
	add_child(new_player)
	_sfx_players.append(new_player)
	return new_player
