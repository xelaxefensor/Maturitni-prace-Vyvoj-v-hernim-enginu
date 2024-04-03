extends CanvasLayer

signal connect_client(address)
signal host_client()
signal disconnect_player()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("%MultiplayerMenu/PlayerName").text = PlayerSettings.player_name
	MultiplayerManager.failed_to_connect.connect(failed_to_connect)
	MultiplayerManager.player_connected.connect(player_connected)
	MultiplayerManager.server_disconnected.connect(server_disconnected)


func _on_play_pressed():
	menus_invisible()
	get_node("%MultiplayerMenu").visible = true
	%MultiplayerMenu/PlayerName.text = PlayerSettings.player_name


func _on_back_pressed():
	menus_invisible()
	match GameManager.game_status:
		"menu":	get_node("%StartMenu").visible = true
		"in_game":	%PauseMenu.visible = true
	


func _on_exit_pressed():
	get_tree().quit()
	
	
func menus_invisible():
	var children : Array = $MarginContainer.get_children()
	for i in children.size():
		children[i].visible = false


func _on_connect_pressed():
	#if get_node("MPMenu/Address").text.is_empty():
	#	return
	connect_client.emit(get_node("%MultiplayerMenu/Address").text)
	menus_invisible()
	%ConnectingMenu.visible = true
	
	
func player_connected(id, _info):
	if id == multiplayer.get_unique_id():
		visible = false
		menus_invisible()


func _on_host_pressed():
	host_client.emit()
	visible = false
	menus_invisible()


func _on_player_name_text_changed(new_text):
	PlayerSettings.player_name = new_text


func failed_to_connect():
	menus_invisible()
	%FailedToConnectMenu.visible = true

func _on_failed_to_connect_back_pressed():
	menus_invisible()
	%MultiplayerMenu.visible = true
	%MultiplayerMenu/PlayerName.text = PlayerSettings.player_name


func _on_abort_pressed():
	disconnect_player.emit()
	menus_invisible()
	%MultiplayerMenu.visible = true
	%MultiplayerMenu/PlayerName.text = PlayerSettings.player_name
	
	
func _input(event):
	if event.is_action_pressed("pause_menu") && GameManager.game_status != "menu":
		if %PauseMenu.visible == false:
			menus_invisible()
			visible = true
			%PauseMenu.visible = true
		else:
			visible = false
			menus_invisible()
		
		
func _on_disconnect_pressed():
	disconnect_player.emit()
	menus_invisible()
	%StartMenu.visible = true


func _on_resume_pressed():
	visible = false   
	menus_invisible()


func server_disconnected():
	visible = true
	menus_invisible()
	%ServerDisconnectedMenu.visible = true


func _on_settings_pressed():
	menus_invisible()
	%SettingsMenu.load_settings()
	%SettingsMenu.visible = true
