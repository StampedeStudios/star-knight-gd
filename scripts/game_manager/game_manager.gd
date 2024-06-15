extends Node
## The [code]Game Manager[/code] is the handler of the game loop.
##
## Every logic which require cooperation between different systems should be handled here to respect the principle "call down signal up".

## User Interface reference.
@onready var user_interface = $UserInterface
## Sound Manager reference.
@onready var sound_manager = $SoundManager

## Handles all UI signals/events triggered from [code]User Interface[/code].
##
## Handles all UI events which require game logic centrilized in the [code]Game Manager[/code] such as:[br]- Load Level;[br]- Save Level;[br]- Pause Game.
func _on_user_interface_event_initiated(event: Enums.GameEvent):
    match event:
        Enums.GameEvent.STARTED:
            var level = load("res://levels/Level1.tscn")
            var hero = load("res://scenes/entities/hero/Hero.tscn")
            var hero_instance = hero.instantiate()
            hero_instance.connect('shoot', _on_hero_shoot)

            if not level:
                print("Error loading level")
                return

            user_interface.hide_all()
            add_child(level.instantiate())
            add_child(hero_instance)
            pass
        _:
            pass

## Handles the bullet spawning process when [code]hero[/code] is shooting.
## 
func _on_hero_shoot(bullet: PackedScene, direction: float, position: Vector2, audio_clip: AudioStream):
    var spawned_bullet = bullet.instantiate()
    add_child(spawned_bullet)
    spawned_bullet.rotation = direction
    spawned_bullet.position = position
    spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
    sound_manager.play_sound_effect(audio_clip)
