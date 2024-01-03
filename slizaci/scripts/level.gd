extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/%Game.peer_loaded.rpc_id(1)
	$/root/Main/%Game.on_game_loaded()
