extends Area2D

var weapon: String


func _on_body_entered(body):
	if not body.name == "Player":
		return
		
	var weapons = body.get_node("Weapons")
