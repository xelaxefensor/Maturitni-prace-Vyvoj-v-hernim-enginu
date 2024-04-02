extends Label

var game
var game_phase

# Called when the node enters the scene tree for the first time.
func _ready():
	game = $/root/Main/Game


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_visible_in_tree():
		game_phase = "Zahřívací kolo"
		if MultiplayerManager.is_online:
			match game.server_game_phase:
				"warmpup":		game_phase = "Zahřívací kolo"
				"round_start": 	game_phase = "Začínám kolo"
				"round_play": 	game_phase = "Kolo v průběhu"
				"round_end": 	game_phase = "Konec kola"
				"game_end": 	game_phase = "Konec hry"
			
			text = str(game_phase)
