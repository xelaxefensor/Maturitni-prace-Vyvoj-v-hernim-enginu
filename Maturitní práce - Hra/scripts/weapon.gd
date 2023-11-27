extends Node2D

@export var magSize:int = 20
@export var ammoSize:int = 120
var magCount
var ammoCount

var bulletSpawn
var reloadTimer
var fireRateTimer

var fireRateZero

@export var fireRateTime:float = 0.104
@export var reloadTime:float = 1.0

@export var bulletForce:float = 3000
var reloading = false

@export var target:Node2D

signal ammoChanged(currentMagCount,currentAmmoCount)

# Called when the node enters the scene tree for the first time.
func _ready():
	magCount=magSize
	ammoCount=ammoSize
	
	bulletSpawn = get_node("BulletSpawn")
	reloadTimer = get_node("ReloadTimer")
	fireRateTimer = get_node("FireRateTimer")
	
	reloadTimer.set_wait_time(reloadTime)
	fireRateTimer.set_wait_time(fireRateTime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("fire") && fireRateZero==true && magCount > 0 && reloading == false:
		var bullet = preload("res://scenes/bullet.tscn").instantiate()
		bullet.innitialize(bulletSpawn.global_position,bulletForce,rotation)
		get_node("/root").add_child(bullet)
		
		ammoChanged.emit(magCount-1,ammoCount)
		
		fireRateZero = false
		fireRateTimer.start()

	var screenCords = target.get_global_transform_with_canvas().get_origin()
	rotation=(screenCords.angle_to_point(get_viewport().get_mouse_position()))

	if rotation < -1.5 or rotation > 1.5:
		get_node("Sprite2D").set_flip_v(true)
	else:
		get_node("Sprite2D").set_flip_v(false)	

func _on_fire_rate_timer_timeout():
	fireRateZero = true

func _input(event):
	if event.is_action_pressed("reload"):
		reloadTimer.start()
		reloading = true


func _on_reload_timer_timeout():
	var ghostBullets = clamp(ammoCount,0,magSize-magCount)
	ammoChanged.emit(magCount+ghostBullets,ammoCount-ghostBullets)
	
	reloading = false


func _on_ammo_changed(currentMagCount, currentAmmoCount):
	magCount = currentMagCount
	ammoCount = currentAmmoCount
