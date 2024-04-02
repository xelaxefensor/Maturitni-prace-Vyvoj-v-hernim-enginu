extends Node2D

@export var player_input:MultiplayerSynchronizer
@export var player:CharacterBody2D

@export var sprite: Sprite2D
@export var projectile_spawn: Node2D
@export var reload_timer: Timer

@export var projectile: String
const PROJECTILE = "res://assets/rifle/bullet.tscn"

@export var bullet_start_force: float = 2000

@export var mag_size: int = 20
@export var ammo_size: int = 120
var mag_count
var ammo_count

var reloading = false

@export var fire_rate_delay: float = 0.5
var current_fire_rate_delay: float = 0


signal ammo_changed(current_mag_count, current_ammo_count)

var is_active = false


# Called when the node enters the scene tree for the first time.
func _ready():
	mag_count=mag_size
	ammo_count=ammo_size
	
	player_input.fire_pressing.connect(fire)
	player_input.reload_just_pressed.connect(reload)
	
	player = get_parent().get_parent()
	
	current_fire_rate_delay = fire_rate_delay
	
	if player.player_id == multiplayer.get_unique_id():
		$/root/Main/PlayerHUD/%Ammo.ammo_visible()
		$/root/Main/PlayerHUD/%Ammo.update_ammmo(mag_count, ammo_count)
		
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_active:
		return
	
	if fire_rate_delay > current_fire_rate_delay:
		current_fire_rate_delay += delta


func fire():
	if not is_active:
		return
	
	if reloading or fire_rate_delay > current_fire_rate_delay:
		return
		
	if mag_count <= 0:
		return
	
	current_fire_rate_delay = 0
	
	spawn_projectile()
	
	ammo_changed.emit(mag_count-1,ammo_count)
	
	$ShotSound.play()


func spawn_projectile():
	if not multiplayer.is_server():
		return
	
	var bullet = preload(PROJECTILE).instantiate()
	bullet.innitialize($ProjectileSpawn.global_position, bullet_start_force, rotation, player.player_id, $/root/Main/Game.players[player.player_id]["team"])
	get_node("/root/Main/Game/Projectiles").add_child(bullet, true)
	
	
func reload():
	if not is_active:
		return
	
	if reloading == true:
		return
	
	reloading = true
	reload_timer.start()
	
	$ReloadSound.play()


func _on_reload_timer_timeout():
	var ghost_bullets = clamp(ammo_count,0,mag_size-mag_count)
	ammo_changed.emit(mag_count+ghost_bullets,ammo_count-ghost_bullets)
	reloading = false


func _on_ammo_changed(current_mag_count, current_ammo_count):
	mag_count = current_mag_count
	ammo_count = current_ammo_count
	
	if player.player_id == multiplayer.get_unique_id():
		$/root/Main/PlayerHUD/%Ammo.update_ammmo(mag_count, ammo_count)


func _on_tree_exiting():
	if player.player_id == multiplayer.get_unique_id():
		$/root/Main/PlayerHUD/%Ammo.ammo_invisible()
