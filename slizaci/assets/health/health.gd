extends Node
class_name Health

@export var max_healt:float = 100
var health:float = 100

signal health_changed
signal health_zero


func _ready():
	health = max_healt 


func take_damage(attack: Attack):
	health =- attack.damage
	health_changed.emit()
	
	
func _on_health_changed():
	check_is_healt_zero()


func check_is_healt_zero():
	if health <= 0:
		health_zero.emit()
	
		$/root/Main/Game.player_died.rpc_id(1, get_parent().player_id)
