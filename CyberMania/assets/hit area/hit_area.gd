extends Area2D

@export var healt:Health  

var player_id = 1
var team_id = 1

func _on_area_entered(area):
	pass

func take_damage(attack: Attack):
	if healt:
		healt.take_damage(attack)
