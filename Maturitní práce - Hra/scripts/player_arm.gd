extends Node2D

var armBase
var armEnd
var itemInHand
var armLenght =	120.0

# Called when the node enters the scene tree for the first time.
func _ready():
	armBase = get_node("arm_base")
	armEnd = get_node("arm_end")
	itemInHand = get_node("Weapon")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var screenCords = self.get_global_transform_with_canvas().get_origin()
	
	armEnd.position = armBase.position + (get_viewport().get_mouse_position() - screenCords).normalized() * clamp(armBase.position.distance_to(armBase.position + (get_viewport().get_mouse_position() - screenCords)), -armLenght, armLenght)
	itemInHand.position = armEnd.position
