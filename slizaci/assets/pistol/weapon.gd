extends Node2D

@export var player_input:MultiplayerSynchronizer

@export var sprite: Sprite2D
@export var projectile_spawn: Node2D
@export var reload_timer: Timer

@export var projectile: String

@export var bullet_start_force: float = 3000

@export var magSize: int = 20
@export var ammoSize: int = 120
var magCount
var ammoCount

var reloading = false


signal ammo_changed(currentMagCount,currentAmmoCount)

# Called when the node enters the scene tree for the first time.
func _ready():
	magCount=magSize
	ammoCount=ammoSize
	
	player_input.fire_pressed.connect(fire)
	player_input.reload_pressed.connect(reload)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func fire():
	var bullet = preload("res://assets/pistol/bullet/bullet.tscn").instantiate()
	bullet.innitialize($ProjectileSpawn.global_position, bullet_start_force, rotation)
	get_node("/root").add_child(bullet)
	
	ammo_changed.emit(magCount-1,ammoCount)
		
	#fireRateZero = false
	#fireRateTimer.start()
	
	
func reload():
	pass



func _on_reload_timer_timeout():
	var ghostBullets = clamp(ammoCount,0,magSize-magCount)
	ammo_changed.emit(magCount+ghostBullets,ammoCount-ghostBullets)
	
	reloading = false


func _on_ammo_changed(currentMagCount, currentAmmoCount):
	magCount = currentMagCount
	ammoCount = currentAmmoCount
