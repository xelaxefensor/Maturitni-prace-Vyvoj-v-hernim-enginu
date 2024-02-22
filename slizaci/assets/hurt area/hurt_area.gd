extends Area2D

var attack = Attack.new()

var player_id = 1
var team_id = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	attack.damage = 10
	attack.knockback_force = 0
	attack.player_id = player_id
	attack.team_id = team_id


func _on_area_entered(area):
	if player_id == area.player_id or team_id == area.team_id:
		return
	
	if area.has_method("take_damage"):
		area.take_damage(attack)
		
	get_parent().queue_free()
