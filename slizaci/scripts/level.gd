extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/Game.level_loaded.rpc_id(1)
