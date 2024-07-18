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


## Literals associated with enemy stats
class EnemyStats:
	const MAX_HEALTH := "max_health"
	const IMPACT_DAMAGE := "impact_damage"
	const SPEED := "speed"
	const GUN := "gun"
	const REWARD := "rewards"


## Literals asssociated with enemy rewards
class EnemyRewards:
	const LIFE := "health"
	const LIFE_AMOUNT := 20
	const COIN := "coin"


## Literals associated with enemy gun
class EnemyGun:
	const FIRE_RATE := "fire_rate"
	const AMMO_DAMAGE := "ammo_damage"
	const AMMO_SPEED := "ammo_speed"
	const AMMO_BURST := "ammo_burst"


## Information on enemy waves
class Waves:
	const FORMATIONS := "formations"
	const STEPS := "steps"
	const ODDS := "odds"
