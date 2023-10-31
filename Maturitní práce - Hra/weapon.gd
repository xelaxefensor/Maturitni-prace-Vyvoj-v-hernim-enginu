extends Node2D

var magSize = 20
var ammoSize = 120
var magCount
var ammoCount

var bulletSpawn
var reloadTimer
var fireRateTimer

var fireRateZero

var bulletForce = 3000
var reloading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	magCount=magSize
	ammoCount=ammoSize
	
	bulletSpawn = get_node("BulletSpawn")
	reloadTimer = get_node("ReloadTimer")
	fireRateTimer = get_node("FireRateTimer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("fire") && fireRateZero==true && magCount > 0 && reloading == false:
		var bullet = preload("res://bullet.tscn").instantiate()
		bullet.innitialize(bulletSpawn.global_position,Vector2(bulletForce,0))
		get_node("/root").add_child(bullet)
		
		magCount -= 1
		
		fireRateZero = false
		fireRateTimer.start()
		
		print("Mag: ", magCount)
		print("Ammo: ", ammoCount)


func _on_fire_rate_timer_timeout():
	fireRateZero = true

func _input(event):
	if event.is_action_pressed("reload"):
		print("reloading")
		reloadTimer.start()
		reloading = true


func _on_reload_timer_timeout():
	var ghostBullets = clamp(ammoCount,0,magSize-magCount)
	magCount += ghostBullets
	ammoCount -= ghostBullets
	
	print("done")
	print("Mag: ", magCount)
	print("Ammo: ", ammoCount)
	
	reloading = false
