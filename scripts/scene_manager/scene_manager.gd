extends Node
## The [code]Scene Manager[/code] is the handler of every level, enemy and hero spawn.
##
## Every logic that involve levels should be handled here.

## Hero is always needed, hence preloaded.
var hero = preload ("res://scenes/entities/hero/Hero.tscn")

## Levels handling
var reached_level: int = 0
var levels = [
    load("res://levels/Level1.tscn"),
]

const BOTTOM_POSITION_OFFSET: int = 150
var viewport_size: Vector2

signal sound_played(audio_clip: AudioStream)
signal hero_ammo_change(ammunition: int, magazine_size: int)
signal quit()

func init(saved_reached_level: int):
    reached_level = saved_reached_level
    ## Refreshing viewport size to handle windows resizing
    viewport_size = get_viewport().size

func load_next_level():
    var hero_instance = hero.instantiate()
    add_child(hero_instance)

    # Set position to bottom center
    hero_instance.position = Vector2(viewport_size.x / 2, viewport_size.y - BOTTOM_POSITION_OFFSET)

    hero_instance.connect('shoot', _on_hero_shoot)
    hero_instance.connect('ammunition_change', _on_hero_ammunition_change)
    hero_instance.connect('quit', _on_quit_request)

    var level = levels[reached_level]
    if not level:
        print("Error loading level")
        return

    add_child(level.instantiate())

## Handles the bullet spawning process when [code]hero[/code] is shooting.
func _on_hero_shoot(bullet: PackedScene, direction: float, location: Vector2, audio_clip: AudioStream):
    var spawned_bullet = bullet.instantiate()
    add_child(spawned_bullet)
    spawned_bullet.rotation = direction
    spawned_bullet.position = location
    spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
    sound_played.emit(audio_clip)

func _on_hero_ammunition_change(ammunition: int, magazine_size: int):
    hero_ammo_change.emit(ammunition, magazine_size)

func _on_quit_request():
    for child in get_children():
        child.queue_free()
    quit.emit()
