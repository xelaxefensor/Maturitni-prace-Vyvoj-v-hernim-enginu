extends Node

@export var server_game_phase = "loading"
#loading
#warmup
#round_start
#game
#round_end

var map = "res://scenes/levels/test_01.tscn"
var player_size = 8
var round_time = 300

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.connection_lost.connect(connection_lost)
	MultiplayerManager.player_disconnected.connect(player_disconnected)
	MultiplayerManager.succeded_to_connect.connect(succeded_to_connect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func connection_lost():
	GameManager.game_status = "menu"
	
	var level = $Level
	for c in level.get_children():
		c.queue_free()
		
	var players = $Players
	for c in players.get_children():
		c.queue_free()


func succeded_to_connect():
	GameManager.game_status = "loading_game"

	
func player_disconnected(id, _info):
	var nd = get_tree().get_nodes_in_group("id"+str(id))
	for c in nd:
		c.queue_free()
	
	
func server_load_game(map, player_size, time):
	GameManager.game_status = "loading"
	server_game_phase = "loading_game"
	self.map = map
	self.player_size = player_size
	round_time = time
	
	var game_load = load(map).instantiate()
	$Level.add_child(game_load, true)
	

@rpc("any_peer", "call_local", "reliable", 1)
func level_loaded():
	var player = preload("res://scenes/player.tscn").instantiate()
	player.id = multiplayer.get_remote_sender_id()
	$Players.add_child(player, true)
	
