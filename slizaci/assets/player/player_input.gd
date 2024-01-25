extends MultiplayerSynchronizer

@export var direction = Vector2(0.0, 0.0)
@export var running = false

@export var mouse_from_centre = Vector2(0.0, 0.0)
@export var mouse_centre:Node2D

var player
var can_process = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	set_process(player.id == multiplayer.get_unique_id())
	
	$/root/Main/%PlayerHUD/%Chat/%LineEdit.focus_entered.connect(cannot_process_input)
	$/root/Main/%PlayerHUD/%Chat/%LineEdit.focus_exited.connect(can_process_input)
	
	
func cannot_process_input():
	can_process = false
	direction = Vector2(0.0, 0.0)
	running = false
	
	
func can_process_input():
	can_process = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if can_process:
		direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
		
		if Input.is_action_just_pressed("player_jump"):
			player.jump_just_pressed.rpc()

		if Input.is_action_just_released("player_jump"):
			player.jump_just_released.rpc()
			
		running = Input.is_action_pressed("player_run")
		
		
		var mouse_centre_screen_cords = mouse_centre.get_global_transform_with_canvas().get_origin()
		mouse_from_centre = (get_viewport().get_mouse_position() - mouse_centre_screen_cords)
