extends Area2D

var attack = Attack.new()

var team_id = 1
var player_id = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	attack.damage = 10
	attack.knockback_force = 0


func _on_area_entered(area):
	for c in self.get_groups():
		for i in area.get_groups():
			if c == i:
				return
	
	if area.has_method("take_damage"):
		area.take_damage(attack)
		
	get_parent().queue_free()
