extends Node

var game_phase = "menu"
#menu
#wait_time
#round_start
#game
#round_end


# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.player_connected.connect(player_connected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func player_connected(id, info):
	game_phase = "wait_time"
