extends Area2D

@export var healt:Health  

func _on_area_entered(area):
	pass

func take_damage(attack: Attack):
	if healt:
		healt.take_damage(attack)
