extends Label


var weapon
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon = get_node("/root/Node2D/Player/player_arm/Weapon")
	weapon.ammoChanged.connect(_on_ammo_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_ammo_changed(currentMagCount,currentAmmoCount):
	text = str(currentMagCount,"/",currentAmmoCount)
	
