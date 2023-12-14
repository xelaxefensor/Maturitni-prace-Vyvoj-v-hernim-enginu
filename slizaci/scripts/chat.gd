extends Control

var chat_text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerManager.player_connected.connect(player_connected)
	MultiplayerManager.player_disconnected.connect(player_disconnected)

func player_connected(id, info):
	if id == multiplayer.get_unique_id():
		self.visible = true
	else:
		send_text_message.rpc(str(info.name)+" se připojil")
	

func player_disconnected(id, info):
	send_text_message.rpc(str(info.name)+" se odpojil")


func _on_line_edit_text_submitted(new_text):
	if new_text.is_empty():
		return
	chat_text += new_text
	send_text_message.rpc(str(MultiplayerManager.player_info.name)+": " + new_text)
	$VBoxContainer/LineEdit.text = ""

@rpc("any_peer", "call_local", "reliable", 2)
func send_text_message(text):
	$VBoxContainer/Label.text += text + "\n"
	$VBoxContainer/Label.lines_skipped = $VBoxContainer/Label.get_line_count()-$VBoxContainer/Label.get_visible_line_count()
