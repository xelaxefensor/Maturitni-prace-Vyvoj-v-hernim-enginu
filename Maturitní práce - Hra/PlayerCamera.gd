extends Camera2D

var maxZoomOut = Vector2(400,200)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("camera_focus")):
		position = (-get_viewport().size / 2.0 + get_viewport().get_mouse_position()).clamp(-maxZoomOut,maxZoomOut) 
	else:
		position = Vector2(0,0)
