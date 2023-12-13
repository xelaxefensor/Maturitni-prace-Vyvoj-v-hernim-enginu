extends Control

signal connect_client(address)
signal host_client()
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MPMenu/PlayerName").text = PlayerSettings.player_name
	$/root/Main/Multiplayer.failed_to_connect.connect(failed_to_connect)
	$/root/Main/Multiplayer.player_connected.connect(player_connected)


func _on_play_pressed():
	menus_invisible()
	get_node("MPMenu").visible = true


func _on_back_pressed():
	menus_invisible()
	get_node("StartMenu").visible = true


func _on_exit_pressed():
	get_tree().quit()
	
	
func menus_invisible():
	var children : Array = get_children()
	for i in children.size():
		children[i].visible = false


func _on_connect_pressed():
	if get_node("MPMenu/Address").text.is_empty():
		return
	connect_client.emit(get_node("MPMenu/Address").text)
	menus_invisible()
	$ConnectingMenu.visible = true
	
	
func player_connected(_id, _info):
	menus_invisible()


func _on_host_pressed():
	host_client.emit()
	menus_invisible()


func _on_player_name_text_changed(new_text):
	PlayerSettings.player_name = new_text


func failed_to_connect():
	menus_invisible()
	$FailedToConnectMenu.visible = true

func _on_failed_to_connect_back_pressed():
	menus_invisible()
	$MPMenu.visible = true


func _on_abort_pressed():
	menus_invisible()
	$MPMenu.visible = true
