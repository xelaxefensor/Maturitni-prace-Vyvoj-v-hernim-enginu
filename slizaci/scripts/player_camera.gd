extends Camera2D

@export var maxZoomOut:Vector2 = Vector2(500,300)
@export var target:Node2D
@export var move_amount = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("camera_focus")):
		var target_screen_cords = target.get_global_transform_with_canvas().get_origin()
		
		position = Vector2(0, 0)
		position =+ ((get_viewport().get_mouse_position() - target_screen_cords)*move_amount).clamp(-maxZoomOut,maxZoomOut)
	else:
		position = Vector2(0, 0)
