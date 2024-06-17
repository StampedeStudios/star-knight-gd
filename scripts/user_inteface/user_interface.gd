extends Control
## Handle all functionalities and events triggered by all UI elements.
##
## Will handle all signal and functionality which cannot be solved internally by its children. [br]Currently handling:[br]- Menu;[br]- How To Play section.[br]-HUD.

## Menu Canvas Layer
@onready var menu: CanvasLayer = $Menu
## HTP Section Canvas Layer
@onready var how_to_play_section: CanvasLayer = $HowToPlaySection
## Heads up display
@onready var hud: CanvasLayer = $HUD

const BTN_SFX = preload ("res://assets/audio/button.wav")
const CHANGE_UI_SFX = preload ("res://assets/audio/change_ui_sfx.wav")

## Signal that handles all UI events that require help from [code]Game Manager[/code].
signal event_initiated(event: Enums.GameEvent)
## Signal that handles all UI sound effects requestes.
signal sound_played(audio_clip: AudioStream)

func _ready():
    how_to_play_section.hide()
    hud.hide()

## Handles all [param event] coming from Menu Canvas Leyer.
func _on_menu_control_triggered(event: Enums.MenuEvent):
    match event:
        Enums.MenuEvent.START_BTN_PRESSED:
            sound_played.emit(BTN_SFX)
            event_initiated.emit(Enums.GameEvent.STARTED)
            pass
        Enums.MenuEvent.QUIT_BTN_PRESSED:
            event_initiated.emit(Enums.GameEvent.QUIT)
            pass
        Enums.MenuEvent.HOW_TO_PLAY_BTN_PRESSED:
            _pop_how_to_play()
            pass
        _:
            pass

## Handles all [param event] coming from How To Play Section.
func _on_how_to_play_section_control_triggered(event: Enums.MenuEvent):
    match event:
        Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED:
            pop_menu()
        _:
            pass

## Hides all menu elements but [code]How to Play section[/code].
func _pop_how_to_play():
    menu.hide()
    sound_played.emit(CHANGE_UI_SFX)
    how_to_play_section.show()

## Hides all menu elements but [code]Menu[/code].
func pop_menu():
    how_to_play_section.hide()
    sound_played.emit(CHANGE_UI_SFX)
    menu.show()

## Hides all UI elements.
func hide_all():
    menu.hide()
    how_to_play_section.hide()

func update_hud(ammunition: int, magazine_size: int):
    hud.update_ammo_count(ammunition, magazine_size)

func show_hud():
    hud.show()