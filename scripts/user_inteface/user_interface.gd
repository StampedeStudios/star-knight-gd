extends Control
## Handle all functionalities and events triggered by all UI elements.
##
## Will handle all signal and functionality which cannot be solved internally by its children. [br]Currently handling:[br]- Menu;[br]- How To Play section.[br]-HUD.

## Menu Canvas Layer
@onready var menu: CanvasLayer = $Menu
## HTP Section Canvas Layer
@onready var how_to_play_section: CanvasLayer = $HowToPlaySection

## Signal that handles all UI events that require help from [code]Game Manager[/code].
signal event_initiated(event: Enums.UIEvent)

func _ready():
    how_to_play_section.hide()

## Handles all [param event] coming from Menu Canvas Leyer.
func _on_menu_control_triggered(event: Enums.MenuEvent):
    match event:
        Enums.MenuEvent.START_BTN_PRESSED:
            event_initiated.emit(Enums.UIEvent.GAME_STARTED)
        Enums.MenuEvent.HOW_TO_PLAY_BTN_PRESSED:
            _pop_how_to_play()
        _:
            pass

## Handles all [param event] coming from How To Play Section.
func _on_how_to_play_section_control_triggered(event: Enums.MenuEvent):
    match event:
        Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED:
            _pop_menu()
        _:
            pass

## Hidden all menu elements but [code]How to Play section[/code].
func _pop_how_to_play():
    menu.hide()
    how_to_play_section.show()

## Hidden all menu elements but [code]Menu[/code].
func _pop_menu():
    how_to_play_section.hide()
    menu.show()

func hide_all():
    menu.hide()
    how_to_play_section.hide()
