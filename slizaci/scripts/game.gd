extends Node

@export var server_game_phase = "loading"
#loading		- Loading map at new level

#warmup 		- pre game phase with freeroam around the map
#			 	- players can spawn

#round_start	- short phase before round start
#				- players are frozen in place and waiting for round to start
#			 	- players can spawn

#round_play 	- actual game play phase
#				- players can spawn based on gamemode

#round_end 		- short phase at the end of a round
#				- players can not spawn

#game_end 		- post game phase, 
#				- players are forzen in place
#				- players can not spawn


const DEFAULT_WARMUP_TIME = 120.0
const DEFAULT_ROUND_START_TIME = 10.0
const DEFAULT_ROUND_PLAY_TIME = 300.0
const DEFAULT_ROUND_END_TIME = 5.0
const DEFAULT_GAME_END_TIME = 30.0


signal game_loaded
signal game_ended


var number_of_rounds = 1
var current_round_number = 0


@export var can_players_spawn = false

var map = "res://scenes/levels/test_01.tscn"
var minimal_player_size = 2
var player_size = 8
var round_time = 300.0

var player_info = {"name" = PlayerSettings.player_name, 
	"color" = PlayerSettings.player_color, 
	"team" = "spectate", 
	"kills" = 0, 
	"deaths" = 0}
var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.connection_lost.connect(connection_lost)
	MultiplayerManager.player_disconnected.connect(player_disconnected)
	MultiplayerManager.succeded_to_connect.connect(succeded_to_connect)
	MultiplayerManager.connection_lost.connect(on_game_ended)
	$/root/Main/%TeamSelect.team_selected.connect(team_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func connection_lost():
	GameManager.game_status = "menu"
	
	var level = %Level
	for c in level.get_children():
		c.queue_free()
		
	var players = %Players
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
	server_game_phase = "loading"
	self.map = map
	self.player_size = player_size
	round_time = time
	
	var game_load = load(map).instantiate()
	%Level.add_child(game_load, true)
	

@rpc("any_peer", "call_local", "reliable", 1)
func peer_loaded():
	if multiplayer.is_server():
		var player = preload("res://scenes/player.tscn").instantiate()
		player.id = multiplayer.get_remote_sender_id()
		%Players.add_child(player, true)
	
		if multiplayer.get_remote_sender_id() == 1:
			server_set_warmup(DEFAULT_WARMUP_TIME)
			
			
func on_game_loaded():
	GameManager.game_status = "in_game"
	_register_player.rpc_id(1, player_info)
	emit_signal("game_loaded")
	
	
#registers new player in players[]
@rpc("any_peer", "call_local",  "reliable", 1)
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	
	
func team_selected(team):
	team_selected_apply.rpc_id(1, team)
	

@rpc("any_peer", "call_local",  "reliable", 1)
func team_selected_apply(team):
	var id = multiplayer.get_remote_sender_id()
	print(players[id][team])
	
		
func on_game_ended():
	emit_signal("game_ended")
	
	

func server_set_warmup(time):
	server_game_phase = "warmup"
	can_players_spawn = true
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_WARMUP_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	

func server_set_round_start(time):
	server_game_phase = "round_start"
	can_players_spawn = true
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_START_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	
	
func server_set_round_play(time):
	server_game_phase = "round_play"
	can_players_spawn = true
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_PLAY_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	
	
func server_set_round_end(time):
	server_game_phase = "round_end"
	can_players_spawn = false
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_END_TIME
	else:
		%PhaseTimer.wait_time = time
		
	%PhaseTimer.start()	


func server_set_game_end(time):
	server_game_phase = "game_end"
	can_players_spawn = false

	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_GAME_END_TIME
	else:
		%PhaseTimer.wait_time = time

	%PhaseTimer.start()	


func _on_game_timer_timeout():
	match server_game_phase:
		"warmup":
			current_round_number = 1
			server_set_round_start(DEFAULT_ROUND_START_TIME)
		"round_start":
			server_set_round_play(DEFAULT_ROUND_PLAY_TIME)
		"round_play":
			server_set_round_end(DEFAULT_ROUND_END_TIME)
		"round_end":
			if current_round_number == number_of_rounds:
				server_set_game_end(DEFAULT_GAME_END_TIME)
			else:
				current_round_number += 1
				server_set_round_start(DEFAULT_ROUND_START_TIME)
		"game_end":
			server_load_game(map, player_size, round_time)
		
		
