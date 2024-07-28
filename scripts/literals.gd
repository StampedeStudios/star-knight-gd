class_name Literals
## Class that contains all literal constants use in the project.


## Literals associated with the player input.
class Inputs:
	const MOVE_UP := "move_up"
	const MOVE_DOWN := "move_down"
	const MOVE_RIGHT := "move_right"
	const MOVE_LEFT := "move_left"
	const SHOOT := "shoot"
	const RELOAD := "reload"
	const QUIT := "quit"


## Literals associated with the signals.
class Signals:
	const SHOOT := "shoot"
	const AMMO_CHANGE := "ammunition_change"
	const ENEMIES_DEFEATED := "enemies_defetead"
	const TIMEOUT := "timeout"
	const QUIT_REQUEST := "quit"
	const DEATH := "death"


## Literals asssociated with enemy rewards
class EnemyRewards:
	const LIFE := "health"
	const LIFE_AMOUNT := 20
