extends Node

#rpc channels
#1 - multiplayer inner workings
#2 - game chat
#3 - gameplay

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id, player_info)
signal server_disconnected
signal failed_to_connect
signal succeded_to_connect
signal connection_lost

var max_connections = 16
const PORT = 7000
const DEFAULT_SERVER_IP = "192.168.0.58"

var is_online = false

var player_info = {"name" = PlayerSettings.player_name, "color" = PlayerSettings.player_color}

var players = {} #Dictionary with all player infos

var latency_counter_is_stopped = true
var latency_time_elapsed := 0.0
	
func _ready():
	get_node("/root/Main/UI/Menu").connect_client.connect(join_game)
	get_node("/root/Main/UI/Menu").host_client.connect(create_game)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	$/root/Main/UI/Menu.disconnect_player.connect(remove_multiplayer_peer)


#Connects to server
#Sets player_info
func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	player_info = {"name" = PlayerSettings.player_name, "color" = PlayerSettings.player_color}
	

#Creates server
#Sets player_info and players[]
#Calls server load func
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, max_connections)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	player_info = {"name" = PlayerSettings.player_name, "color" = PlayerSettings.player_color}
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	$/root/Main/Game.server_load_game("res://scenes/levels/test_01.tscn", 0, 0)
	
	is_online = true


#Disconects MP peer
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()
	connection_lost.emit()
	
	is_online = false


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


#registers new player in players[]
@rpc("any_peer", "call_remote",  "reliable", 1)
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	player_disconnected.emit(id, players[id])
	players.erase(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	succeded_to_connect.emit()
	
	is_online = true
	

func _on_connected_fail():
	remove_multiplayer_peer()
	failed_to_connect.emit()


func _on_server_disconnected():
	remove_multiplayer_peer()
	server_disconnected.emit()
	
	
#PING
func latency_ping():
	if is_online:
		latency_counter_is_stopped = false
		server_received_latance_ping.rpc_id(1)
	
	
@rpc("any_peer", "call_local", "reliable", 5)
func server_received_latance_ping():
	client_received_latance_ping.rpc_id(multiplayer.get_remote_sender_id())


@rpc("authority", "call_local", "reliable", 5)
func client_received_latance_ping():
	latency_counter_is_stopped = true
	print(latency_time_elapsed)
	latency_time_elapsed = 0.0


func _process(delta):
	if latency_counter_is_stopped:
		latency_ping()
	if !latency_counter_is_stopped:
		latency_time_elapsed += delta
