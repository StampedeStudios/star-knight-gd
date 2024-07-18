class_name Enums
## Defines all constant enums used by the entire codebase.

## All Menu and sub-menu events triggered which require to be handled by the [code]User Interface[/code].
enum MenuEvent {
	START_BTN_PRESSED,
	CONTINUE_BTN_PRESSED,
	RESTART_BTN_PRESSED,
	HOW_TO_PLAY_BTN_PRESSED,
	BACK_TO_MENU_BTN_PRESSED,
	QUIT_BTN_PRESSED,
}

## All UI events triggered which require to be handled by [code]Game Manager[/code].
enum GameEvent {
	STARTED,
	PAUSED,
	QUIT,
}

enum EnemyType {
	SHIP,
}

enum Position { TOP, LEFT, RIGHT }
