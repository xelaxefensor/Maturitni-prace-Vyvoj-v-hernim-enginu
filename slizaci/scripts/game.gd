extends Node


var map = "res://scenes/levels/test_01.tscn"
var player_size = 8
var round_time = 300

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.succeded_to_connect.connect(connected)
	MultiplayerManager.connection_lost.connect(connection_lost)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func connection_lost():
	var level = $LevelSpawner
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()


func connected():
	GameManager.game_phase = "loading_game"
	
	
func server_load_game(map, player_size, time):
	GameManager.game_phase = "loading_game"
	self.map = map
	self.player_size = player_size
	round_time = time
	
	var game_load = load(map).instantiate()
	$LevelSpawner.add_child(game_load)
	

@rpc("any_peer", "call_local", "reliable", 1)
func level_loaded():
	print("Loaded")
	
