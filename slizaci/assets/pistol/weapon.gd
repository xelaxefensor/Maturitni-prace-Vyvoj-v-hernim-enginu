extends Node2D

@export var player_input:MultiplayerSynchronizer

@export var sprite: Sprite2D
@export var projectile_spawn: Node2D
@export var reload_timer: Timer

@export var projectile: String

@export var bullet_start_force: float = 3000

@export var mag_size: int = 20
@export var ammo_size: int = 120
var mag_count
var ammo_count

var reloading = false

var fire_rate_time


signal ammo_changed(currentMagCount,currentAmmoCount)

# Called when the node enters the scene tree for the first time.
func _ready():
	mag_count=mag_size
	ammo_count=ammo_size
	
	player_input.fire_pressed.connect(fire)
	player_input.reload_pressed.connect(reload)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func fire():
	if reloading:
		return
	
	spawn_projectile()
	
	ammo_changed.emit(mag_count-1,ammo_count)
		
	#fireRateZero = false
	#fireRateTimer.start()


func spawn_projectile():
	if not multiplayer.is_server():
		return
	
	var bullet = preload("res://assets/pistol/bullet/bullet.tscn").instantiate()
	bullet.innitialize($ProjectileSpawn.global_position, bullet_start_force, rotation)
	get_node("/root").add_child(bullet)
	
	
func reload():
	reloading = true


func _on_reload_timer_timeout():
	var ghost_bullets = clamp(ammo_count,0,mag_size-mag_count)
	ammo_changed.emit(mag_count+ghost_bullets,ammo_count-ghost_bullets)
	
	reloading = false


func _on_ammo_changed(current_mag_count, current_ammo_count):
	mag_count = current_mag_count
	ammo_count = current_ammo_count
