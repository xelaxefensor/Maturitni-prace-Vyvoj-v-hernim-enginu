extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.player_connected.connect(player_connected)
	MultiplayerManager.player_disconnected.connect(player_disconnected)
	MultiplayerManager.connection_lost.connect(connection_lost)

func player_connected(id, info):
	#Visibles chat if players connects
	if id == multiplayer.get_unique_id():
		get_parent().visible = true
	
	if multiplayer.is_server():
		send_text_message.rpc("[color=green]" + str(info.name) + " se připojil[/color]")
	

func player_disconnected(_id, info):
	if multiplayer.is_server():
		send_text_message.rpc("[color=red]" + str(info.name) +" se odpojil[/color]")
	

func connection_lost():
	clear_chat()


#Sends text to every MP peer
func _on_line_edit_text_submitted(new_text):
	if new_text.is_empty():
		return
	send_text_message.rpc("[color=" + str(MultiplayerManager.player_info.color.to_html()) + "]" + str(MultiplayerManager.player_info.name) + ":[/color] " + new_text)
	%LineEdit.text = ""


@rpc("any_peer", "call_local", "reliable", 2)
func send_text_message(text):
	%RichTextLabel.text += text + "\n"
	
	
func clear_chat():
	%RichTextLabel.text = ""


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), $LineEdit.size).has_point(evLocal.position):
			$LineEdit.release_focus()
	
	if event.is_action_pressed("chat") and not $LineEdit.has_focus():
		$LineEdit.grab_focus()
		
		await get_tree().create_timer(0.001).timeout
		
		if $LineEdit.text[$LineEdit.text.length()-1] == "t" or $LineEdit.text[$LineEdit.text.length()-1] == "T":
			$LineEdit.delete_char_at_caret()

