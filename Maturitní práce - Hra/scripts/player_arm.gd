extends Node2D

var armBase
var armEnd
@export var itemInHand:Node2D
@export var armLenght:float = 120.0

@export var upperArmSprite:Node2D
@export var lowerArmSprite:Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	armBase = get_node("ArmBase")
	armEnd = get_node("ArmEnd")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var screenCords = self.get_global_transform_with_canvas().get_origin()
	
	armEnd.position = armBase.position + (get_viewport().get_mouse_position() - screenCords).normalized() * clamp(armBase.position.distance_to(armBase.position + (get_viewport().get_mouse_position() - screenCords)), -armLenght, armLenght)
	itemInHand.position = armEnd.position


	var middlePoint = armBase.position - (armBase.position-armEnd.position) / 2 + Vector2((armLenght-armBase.position.distance_to(armEnd.position)),(armLenght-armBase.position.distance_to(armEnd.position))/2)

	upperArmSprite.position = armBase.position
	upperArmSprite.rotation = armBase.position.angle_to_point(middlePoint)
	
	lowerArmSprite.position = middlePoint
	lowerArmSprite.rotation = middlePoint.angle_to_point(armEnd.position)
