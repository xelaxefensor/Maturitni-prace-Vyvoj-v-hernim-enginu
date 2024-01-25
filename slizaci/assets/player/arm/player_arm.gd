extends Node2D

var arm_base
var arm_end
@export var item_in_hand:Node2D
@export var arm_lenght:float = 120.0

# Called when the node enters the scene tree for the first time.
func _ready():
	arm_base = get_node("ArmBase")
	arm_end = get_node("ArmEnd")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	arm_end.position = arm_base.position + $"../../InputSynchronizer".mouse_from_centre.normalized() * clamp(arm_base.position.distance_to(arm_base.position + $"../../InputSynchronizer".mouse_from_centre), -arm_lenght, arm_lenght)
	#item_in_hand.position = arm_end.position
	
	$ArmGraphics.set_point_position(0,arm_base.position)
	$ArmGraphics.set_point_position(1,arm_end.position)


	#ArmSprite.position = armBase.position
	#ArmSprite.rotation = armBase.position.angle_to_point(armEnd.position)
	
