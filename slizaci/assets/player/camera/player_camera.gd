extends Camera2D

@export var maxZoomOut:Vector2 = Vector2(500,300)
@export var target:Node2D
@export var move_amount = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("camera_focus")):
		
		position = Vector2(0, 0)
		position =+ ($"../InputSynchronizer".mouse_from_centre * move_amount).clamp(-maxZoomOut,maxZoomOut)
	else:
		position = Vector2(0, 0)
		
	
