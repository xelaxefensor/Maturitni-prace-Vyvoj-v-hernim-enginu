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

@export var game_mode = "deathmatch"
#deathmatch		- 
#				- all vs all, team vs team

#flag			- Capture the flag
#				- 2 or more teams

const DEFAULT_WARMUP_TIME = 30.0
const DEFAULT_ROUND_START_TIME = 5.0
const DEFAULT_ROUND_PLAY_TIME = 300.0
const DEFAULT_ROUND_END_TIME = 0.01
const DEFAULT_GAME_END_TIME = 10.0


signal game_loaded
signal game_ended
signal team_select(visibility)


var number_of_rounds = 1 #double the rounds to win
var current_round_number = 0

@export var can_players_spawn = false

var map = "res://assets/levels/lab.tscn"
var minimal_player_size = 1
var max_team_players = 999
var round_time = 300.0

var score_to_win_round = 50
var score_to_win_game = 1

#var rounds_to_win_game = 1

var player_info = {"name" = PlayerSettings.player_name, 
	"color" = PlayerSettings.player_color, 
	"team" = -1, #0 = spactate, 1 or more = actual teams 
	"kills" = 0, 
	"deaths" = 0,
	"spawned" = false}

@export var players = {}

var number_of_teams = 2
var team_info = {"is_full" = false,
	 "max_players" = 4,
	 "players" = 0,
	 "can_join" = true,
	 "round_score" = 0,
	 "game_score" = 0
	}
	
@export var teams = {}	

##var team_score = {"round_score" = 0,
##	"game_score" = 0
#}

#@export var team_scores = {}

#var player_score = {"round_score" = 0,
#	"game_score" = 0
#}

#@export var player_scores = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.connection_lost.connect(connection_lost)
	MultiplayerManager.player_disconnected.connect(player_disconnected)
	MultiplayerManager.succeded_to_connect.connect(succeded_to_connect)
	$/root/Main/%TeamSelect.team_selected.connect(team_selected)

	#score_to_win_game = number_of_rounds/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_info.team > 0 and !player_info.spawned and can_players_spawn:
		player_info.spawned = true
		spawn_player.rpc_id(1)


func connection_lost():
	GameManager.game_status = "menu"
	player_info.team = 0
	player_info.spawned = false
	players = {}
	teams = {}
	can_players_spawn = false
	
	var level = %Level
	for c in level.get_children():
		c.queue_free()
	
	var del_players = %Players
	for c in del_players.get_children():
		c.queue_free()
		
	var del_projectiles= %Projectiles
	for c in del_projectiles.get_children():
		c.queue_free()
		
	game_ended.emit()


func succeded_to_connect():
	GameManager.game_status = "loading_game"

	
func player_disconnected(id, _info):
	var nd = get_tree().get_nodes_in_group("player_id_"+str(id))
	for c in nd:
		c.queue_free()
		
	var old_team = players[id]["team"]
	teams[old_team]["players"] -= 1
	
	
func server_load_game(map, player_size, time):
	GameManager.game_status = "loading"
	server_game_phase = "loading"
	self.map = map
	max_team_players = player_size
	round_time = time
		
	var game_load = load(map).instantiate()
	%Level.add_child(game_load, true)
	

@rpc("any_peer", "call_local", "reliable", 1)
func peer_loaded():
	if multiplayer.is_server():
		if multiplayer.get_remote_sender_id() == 1:
			server_set_warmup(DEFAULT_WARMUP_TIME)
			
			
func on_game_loaded():
	player_info["name"] = PlayerSettings.player_name	
	player_info["color"] = PlayerSettings.player_color
	
	teams[0] = team_info.duplicate()
	teams[0]["max_players"] = 99

	for i in number_of_teams:
		teams[i+1] = team_info.duplicate()
	
	GameManager.game_status = "in_game"
	players_info_changed.rpc(player_info)
	emit_signal("game_loaded")
	team_selected(0)
	team_select.emit("visible")
	
	
@rpc("any_peer", "call_local",  "reliable", 1)
func players_info_changed(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	
	
func team_selected(team):
	if teams[team]["can_join"] and !teams[team]["is_full"]:
		team_changed.rpc_id(1, team)
		player_info.team = team
		players_info_changed.rpc(player_info)
		team_select.emit("invisible")
		
		
@rpc("any_peer", "call_local",  "reliable", 1)
func team_changed(team):
	var id = multiplayer.get_remote_sender_id()
	
	if !players[id]["team"] == -1:
		var old_team = players[id]["team"]
		teams[old_team]["players"] -= 1
		
		if teams[old_team]["players"] <= teams[old_team]["max_players"]:
			teams[old_team]["is_full"] = false
	
	teams[team]["players"] += 1
	if teams[team]["players"] >= teams[team]["max_players"]:
		teams[team]["is_full"] = true
		
	players[id]["team"] = team
	despawn_player.rpc_id(1, id)
	

@rpc("any_peer", "call_local", "reliable", 7)
func spawn_player():
	if not multiplayer.is_server():
		return
	
	var player = preload("res://assets/player/player.tscn").instantiate()
	player.player_id = multiplayer.get_remote_sender_id()

	var spawn_points = get_tree().get_nodes_in_group("player_spawn_point_team_"+str(players[multiplayer.get_remote_sender_id()]["team"]))

	if spawn_points.is_empty():
		return
		
	if spawn_points.size() == 1:
		player.position = spawn_points[0].position
	else:
		var rng = RandomNumberGenerator.new()
		var my_random_number = rng.randf_range(0, spawn_points.size()-1)
		player.position = spawn_points[my_random_number].position
	
	%Players.add_child(player, true)
	
	
func despawn_all_players():
	for i in players.size():
		var arr = players.keys()
		despawn_player.rpc_id(1, arr[i])
			
	
@rpc("authority", "call_local", "reliable", 2)
func despawn_player(id):
	var player = get_tree().get_nodes_in_group("player_id_"+str(id))
	
	if player.is_empty():
		return
	for c in player:
		c.queue_free()
	
	player_despawned.rpc_id(id)
	

@rpc("any_peer", "call_local", "reliable", 2)
func player_despawned():
	player_info.spawned = false
	

func server_set_warmup(time):
	server_game_phase = "warmup"
	can_players_spawn = true
	
	reset_score()
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_WARMUP_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	

func server_set_round_start(time):
	server_game_phase = "round_start"
	can_players_spawn = true
	
	reset_round_score()
	despawn_all_players()
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_START_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	
	
func server_set_round_play(time):
	server_game_phase = "round_play"
	can_players_spawn = true
	
	reset_round_score()
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_PLAY_TIME
	else:
		%PhaseTimer.wait_time = time
	
	%PhaseTimer.start()	
	
	
func server_set_round_end(time):
	server_game_phase = "round_end"
	can_players_spawn = false
	
	#despawn_all_players()
	
	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_ROUND_END_TIME
	else:
		%PhaseTimer.wait_time = time
		
	%PhaseTimer.start()	

@rpc("authority", "call_local")
func server_set_game_end(time):
	server_game_phase = "game_end"
	can_players_spawn = false
	
	$Level/Map/LevelCamera2D.make_current()

	if time == 0:
		%PhaseTimer.wait_time = DEFAULT_GAME_END_TIME
	else:
		%PhaseTimer.wait_time = time

	%PhaseTimer.start()
	
	if multiplayer.is_server():
		if teams[1]["game_score"] > teams[2]["game_score"]:
			do_big_notification.rpc("Tým 1 vyhrál hru", 5.0)
		elif teams[1]["game_score"] < teams[2]["game_score"]:
			do_big_notification.rpc("Tým 2 vyhrál hru", 5.0)
		else:
			do_big_notification.rpc("Remíza", 5.0)
		

func _on_phase_timer_timeout():
	match server_game_phase:
		"warmup":
			current_round_number = 1
			server_set_round_start(DEFAULT_ROUND_START_TIME)
		"round_start":
			server_set_round_play(DEFAULT_ROUND_PLAY_TIME)
		"round_play":
			if teams[1]["round_score"] > teams[2]["round_score"]:
				teams[1]["game_score"] += 1
			elif teams[1]["round_score"] < teams[2]["round_score"]:
				teams[2]["game_score"] += 1
				
			server_set_round_end(DEFAULT_ROUND_END_TIME)
		"round_end":
			if current_round_number == number_of_rounds:
				server_set_game_end.rpc(DEFAULT_GAME_END_TIME)
			else:
				current_round_number += 1
				server_set_round_start(DEFAULT_ROUND_START_TIME)
		"game_end":
			server_load_game(map, max_team_players, round_time)
		
	
func _input(event):
	if event.is_action_pressed("team_select") and not $/root/Main/PlayerHUD/%Chat/LineEdit.has_focus():
		team_select.emit("switch")


@rpc("authority", "call_local", "reliable")
func player_died(dead_player_id, killer_player_id):
	despawn_player.rpc_id(1, dead_player_id)
	
	teams[players[killer_player_id]["team"]]["round_score"] += 1
	
	check_round_to_win_team_score(players[killer_player_id]["team"])


func check_round_to_win_team_score(team_id):
	if server_game_phase == "round_play":
		get_node("/root/Main/PlayerHUD/MarginContainer/VBoxContainer/HBoxContainer2/Team"+str(team_id)).text = str(teams[team_id]["round_score"])
		if teams[team_id]["round_score"] >= score_to_win_round:
			teams[team_id]["game_score"] += 1
			teams[team_id]["round_score"] = 0
		
			check_round_to_win_team_game(team_id)
		
			if not teams[team_id]["game_score"] >= score_to_win_game:
				team_won_round(team_id)
				server_set_round_end(DEFAULT_ROUND_END_TIME)
		

func check_round_to_win_team_game(team_id):
	if server_game_phase == "round_play":
		if teams[team_id]["game_score"] >= score_to_win_game:
			team_won_game(team_id)
			server_set_game_end.rpc(DEFAULT_GAME_END_TIME)


func reset_score():
	for c in teams:
		teams[c]["round_score"] = 0
		teams[c]["game_score"] = 0
		
		get_node("/root/Main/PlayerHUD/MarginContainer/VBoxContainer/HBoxContainer2/Team"+str(1)).text = "0"
		get_node("/root/Main/PlayerHUD/MarginContainer/VBoxContainer/HBoxContainer2/Team"+str(2)).text = "0"
		
func reset_round_score():
	for c in teams:
		teams[c]["round_score"] = 0


func team_won_round(winning_team_id):
	do_big_notification.rpc("Tým " + str(winning_team_id) + " vyhrál kolo", 5.0)
	
	
func team_won_game(winning_team_id):
	do_big_notification.rpc("Tým " + str(winning_team_id) + " vyhrál hru", 5.0)


@rpc("any_peer", "call_local", "reliable")
func do_big_notification(text:String, time_up:float):
	var notification = $/root/Main/PlayerHUD/%BigNotification
	
	notification.text = text
	notification.visible = true
	
	await get_tree().create_timer(time_up).timeout

	notification.visible = false
