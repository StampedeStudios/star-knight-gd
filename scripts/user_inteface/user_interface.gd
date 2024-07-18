extends Control
## Handle all functionalities and events triggered by all UI elements.
##
## Will handle all signal and functionality which cannot be solved internally by its children. [br]Currently handling:[br]- Menu;[br]- How To Play section.[br].

## Menu Canvas Layer
@onready var menu: CanvasLayer = $Menu
## HTP Section Canvas Layer
@onready var how_to_play_section: CanvasLayer = $HowToPlaySection
## Death screen
@onready var death_screen = $DeathScreen

const BTN_SFX = preload("res://assets/audio/button.wav")
const CHANGE_UI_SFX = preload("res://assets/audio/change_ui_sfx.wav")


func _ready():
	how_to_play_section.hide()

	# Set starting score to zero
	death_screen.init(0)
	death_screen.hide()


## Handles all [param event] coming from Menu Canvas Leyer.
func _on_menu_control_triggered(event: Enums.MenuEvent):
	match event:
		Enums.MenuEvent.START_BTN_PRESSED:
			SoundManager.play_sound_effect(BTN_SFX)
			SceneManager.start_waves()
			hide_all()
			pass
		Enums.MenuEvent.CONTINUE_BTN_PRESSED:
			SoundManager.play_sound_effect(BTN_SFX)
			SceneManager.unstop()
			hide_all()
			pass
		Enums.MenuEvent.QUIT_BTN_PRESSED:
			get_tree().quit()
			pass
		Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED:
			SceneManager.clean_scene()
			menu.set_quick_menu(false)
			pop_menu()
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
			if get_tree().paused:
				menu.set_quick_menu(true)
			else:
				menu.set_quick_menu(false)

			pop_menu()
		_:
			pass


## Hides all menu elements but [code]How to Play section[/code].
func _pop_how_to_play():
	menu.hide()
	SoundManager.play_sound_effect(CHANGE_UI_SFX)
	how_to_play_section.show()


## Hides all menu elements but [code]Menu[/code].
func pop_menu():
	how_to_play_section.hide()
	death_screen.hide()
	SoundManager.play_sound_effect(CHANGE_UI_SFX)
	menu.show()


func pop_quick_menu():
	menu.set_quick_menu(true)
	pop_menu()


## Hides all menu elements but [code]Menu[/code].
func pop_death_screen(score: int):
	menu.hide()
	how_to_play_section.hide()
	death_screen.init(score)
	death_screen.show()


## Hides all UI elements.
func hide_all():
	menu.hide()
	how_to_play_section.hide()
	death_screen.hide()


func _on_death_screen_control_triggered(event):
	match event:
		Enums.MenuEvent.RESTART_BTN_PRESSED:
			SoundManager.play_sound_effect(BTN_SFX)
			SceneManager.restart()
			hide_all()
			pass
		Enums.MenuEvent.BACK_TO_MENU_BTN_PRESSED:
			menu.set_quick_menu(false)
			pop_menu()
			pass
		_:
			pass
