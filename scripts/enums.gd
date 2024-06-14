class_name Enums
## Defines all constant enums used by the entire codebase.

## All Menu and sub-menu events triggered which require to be handled by the [code]User Interface[/code].
enum MenuEvent {
    START_BTN_PRESSED,
    HOW_TO_PLAY_BTN_PRESSED,
    BACK_TO_MENU_BTN_PRESSED,
}

## All UI events triggered which require to be handled by [code]Game Manager[/code].
enum GameEvent {
    STARTED,
    PAUSED,
    QUIT,
}
