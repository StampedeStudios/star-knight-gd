extends Node
## The [code]Sound Manager[/code] is the handler of the all sound effects and background music.

## Handles constants playing of music in a loop without interrupting whenever a new level is loaded.
@onready var music_player = $MusicPlayer

## Number of AudioStreamPlayer that will be created as starting pool to execute Sound effects.
@export_range(1, 20) var sfx_pool_size: int = 3

## Pool of SFX Audio Stream Players.
var sfx_players := []
var rng = RandomNumberGenerator.new()

## Handle startup events:[br]- Initialization of SFX players pool;
func _ready():
	# Initialize Pool
	for i in range(sfx_pool_size):
		var sfx_player = AudioStreamPlayer.new()
		add_child(sfx_player)
		sfx_players.append(sfx_player)

## Function that consent a sound effect to be played whenever required applying a random pitch scale.
func play_sound_effect_random_pitch(clip: AudioStream):
	var player: AudioStreamPlayer = _get_available_sfx_player()
	player.set_stream(clip)
	player.pitch_scale = rng.randf_range(0.8, 1.2)
	player.play()

## Function that consent a sound effect to be played whenever required.
func play_sound_effect(clip: AudioStream):
	var player: AudioStreamPlayer = _get_available_sfx_player()
	player.set_stream(clip)
	player.play()

## Provide a free SFX player
## 
## Loop through all AudioStreamPlayer to fetch one that is not already playing a sound effect. If no player are available it creates a new one and add it to the pool.
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player

	push_warning("All AudioStreamPlayer are busy, adding a new one to the pool: {%s}" % sfx_players.size())
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	sfx_players.append(new_player)
	return new_player
