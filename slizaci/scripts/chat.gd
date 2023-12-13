extends Control

var peer_id
var player_info = {}
var chat_text = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/Multiplayer.player_connected.connect(player_connected)


func player_connected(id, info):
	self.visible = true
	peer_id = id
	player_info = info


func _on_line_edit_text_submitted(new_text):
	chat_text += new_text
	send_text_message.rpc(new_text)

@rpc("any_peer", "call_local", "reliable", 2)
func send_text_message(text):
	$VBoxContainer/VScrollBar/Label.text += str($/root/Main/Multiplayer.players[multiplayer.get_remote_sender_id()].name)+": " + text + "\n"
