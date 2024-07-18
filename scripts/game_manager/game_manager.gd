extends Node
## The [code]Game Manager[/code] is the handler of the game loop.
##
## Every logic which require cooperation between different systems should be handled here to respect the principle "call down signal up".


func _ready():
	# TODO: load saved data to fetch reached wave index
	print("[Game Manager] - Starting game...")
	SceneManager.init(0)
