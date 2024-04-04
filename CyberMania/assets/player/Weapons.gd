extends Node2D 

var weapons:Array = []

@export var arm:Node
@export var player_input:MultiplayerSynchronizer


func _ready():
	player_input.weapon_selected.connect(weapon_selected)
	
	for i in get_children():
		weapons.append(i)
		
	for i in weapons.size():
		deactivate_weapon(i)
		
	switch_weapon(0)


func activate_weapon(index):
	weapons[index].is_active = true
	arm.item_in_hand = weapons[index]
	
	weapons[index].visible = true
	
	$/root/Main/PlayerHUD/%Ammo.update_ammmo(weapons[index].mag_count, weapons[index].ammo_count)


func deactivate_weapon(index):
	weapons[index].is_active = false
	arm.item_in_hand = null
	
	weapons[index].visible = false


func switch_weapon(new_weapon_id):
	for i in weapons.size():
		deactivate_weapon(i)
		
	activate_weapon(new_weapon_id)


func weapon_selected(index):
	if index > weapons.size() - 1:
		return
		
	switch_weapon(index)

