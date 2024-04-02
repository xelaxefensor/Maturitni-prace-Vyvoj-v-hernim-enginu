extends Node
class_name Health

@export var max_healt:float = 100
var health:float = 100

signal health_changed
signal health_zero

var last_damage_taken_from_player_id = 1

@export var is_dead = false


func _ready():
	health = max_healt 


func take_damage(attack: Attack):
	last_damage_taken_from_player_id = attack.player_id
	health -= attack.damage
	health_changed.emit()
	
	take_damage_effect.rpc()

	
@rpc("authority", "call_local", "unreliable")
func take_damage_effect():
	get_parent().get_node("HitSound").play()
	get_parent().get_node("Smoothing2D/AnimatedSprite2D").modulate = Color(255,255,255,255)

	await get_tree().create_timer(0.2).timeout

	get_parent().get_node("Smoothing2D/AnimatedSprite2D").modulate = Color(1,1,1,1)
	
	
func _on_health_changed():
	check_is_healt_zero()


func check_is_healt_zero():
	if health <= 0 and not is_dead:
		health_zero.emit()
		is_dead = true
		
		await get_tree().create_timer(1.0).timeout
	
		$/root/Main/Game.player_died.rpc_id(1 , get_parent().player_id, last_damage_taken_from_player_id)
