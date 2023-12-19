extends Node

var game_phase = "menu"
#menu
#loading_game
#round_start
#game
#round_end

var map = "res://scenes/maps/test_01.tscn"
var player_size = 8
var round_time = 300

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.succeded_to_connect.connect(connected)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func connected():
	game_phase = "loading_game"
	
	
func server_load_game(map, player_size, time):
	game_phase = "loading_game"
	self.map = map
	self.player_size = player_size
	round_time = time
	
	var game_load = load(map)
	

func level_loaded():
	print("Loaded")
	
