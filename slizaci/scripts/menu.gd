extends Control

signal connect_client(address)
signal host_client()
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MPMenu/PlayerName").text = PlayerSettings.player_name
	$/root/Main/Multiplayer.failed_to_connect.connect(failed_to_connect)
	$/root/Main/Multiplayer.player_connected.connect(player_connected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	get_node("StartMenu").visible = false
	get_node("MPMenu").visible = true


func _on_back_pressed():
	get_node("MPMenu").visible = false
	get_node("StartMenu").visible = true


func _on_exit_pressed():
	get_tree().quit()


func _on_connect_pressed():
	if get_node("MPMenu/Address").text.is_empty():
		return
	connect_client.emit(get_node("MPMenu/Address").text)
	get_node("MPMenu").visible = false
	$ConnectingMenu.visible = true
	
func player_connected(_id, _info):
	$ConnectingMenu.visible = false


func _on_host_pressed():
	host_client.emit()
	get_node("MPMenu").visible = false


func _on_player_name_text_changed(new_text):
	PlayerSettings.player_name = new_text


func failed_to_connect():
	$FailedToConnectMenu.visible = true

func _on_failed_to_connect_back_pressed():
	$FailedToConnectMenu.visible = false
	$MPMenu.visible = true


func _on_abort_pressed():
	$ConnectingMenu.visible = false
	$MPMenu.visible = true
