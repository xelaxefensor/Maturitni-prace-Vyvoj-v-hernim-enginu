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

var player_info = {"name" = PlayerSettings.player_name}

var players = {}
var players_loaded = 0

	
func _ready():
	get_node("/root/Main/Menu").connect_client.connect(join_game)
	get_node("/root/Main/Menu").host_client.connect(create_game)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	$/root/Main/Menu.disconnect_player.connect(remove_multiplayer_peer)

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	player_info = {"name" = PlayerSettings.player_name}
	

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, max_connections)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	player_info = {"name" = PlayerSettings.player_name}
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	GameManager.server_load_game("res://scenes/maps/test_01.tscn", 0, 0)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
	players.clear()
	connection_lost.emit()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("authority", "call_local", "reliable", 1)
func load_game(game_scene_path):
	#get_tree().change_scene_to_file(game_scene_path)
	pass


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable", 1)
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			#$/root/Game.start_game()
			players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


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
	

func _on_connected_fail():
	remove_multiplayer_peer()
	failed_to_connect.emit()


func _on_server_disconnected():
	remove_multiplayer_peer()
	server_disconnected.emit()
