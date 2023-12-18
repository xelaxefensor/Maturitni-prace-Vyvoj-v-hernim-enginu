extends Label


@export var weapon:Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon.ammoChanged.connect(_on_ammo_changed)
	_on_ammo_changed(weapon.magCount,weapon.ammoCount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_ammo_changed(currentMagCount,currentAmmoCount):
	text = str(currentMagCount,"/",currentAmmoCount)
	
