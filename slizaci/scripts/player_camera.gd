extends Camera2D

@export var maxZoomOut:Vector2 = Vector2(500,300)
@export var target:Node2D
@export var lookAhead:Vector2 = Vector2(0.8,0.3)
@export var speed:float = 5

var placeHolder
@export var border:Vector2 = Vector2(100,150)

@export var resetTime:float = 2.0

var resetTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	resetTimer = get_node("ResetTimer")
	placeHolder = target.global_position
	
	resetTimer.set_wait_time(resetTime)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_pressed("camera_focus")):
		position = (-get_viewport().size / 2.0 + get_viewport().get_mouse_position()).clamp(-maxZoomOut,maxZoomOut) + target.global_position
		resetTimer.start()
	else:
		if (Vector2(target.global_position.x,0).distance_to(Vector2(placeHolder.x,0)) >  border.x):
			position.x = target.position.x + target.velocity.x * lookAhead.x
			placeHolder.x = target.global_position.x - border.x * ((target.global_position.x-placeHolder.x)/abs(target.global_position.x-placeHolder.x))
			resetTimer.start()
		if (Vector2(0,target.global_position.y).distance_to(Vector2(0,placeHolder.y)) >  border.y):
			position.y = target.position.y + target.velocity.y * lookAhead.y
			placeHolder.y = target.global_position.y - border.y * ((target.global_position.y-placeHolder.y)/abs(target.global_position.y-placeHolder.y))
			resetTimer.start()
			


func _on_reset_timer_timeout():
	position = target.position
	placeHolder = target.position
