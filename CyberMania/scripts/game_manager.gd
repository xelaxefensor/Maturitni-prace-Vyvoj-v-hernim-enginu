extends Node

#menu
#ingame
#loading
var game_status = "menu"

func _process(delta):
	if game_status == "menu":
		$/root/Main/Camera2D.enabled = true
	else:
		$/root/Main/Camera2D.enabled = false
