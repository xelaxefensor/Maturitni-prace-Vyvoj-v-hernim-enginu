extends MultiplayerSynchronizer

@export var direction = Vector2(0.0, 0.0)
@export var jumping = false
@export var running = false

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	set_process(player.id == multiplayer.get_unique_id())
	
	$/root/Main/%PlayerHUD/%Chat/%LineEdit.focus_entered.connect(cannot_process_input)
	$/root/Main/%PlayerHUD/%Chat/%LineEdit.focus_exited.connect(can_process_input)
	
	
func _enter_tree():
	player = get_parent()
	set_multiplayer_authority(player.id)
	
	
func cannot_process_input():
	set_process(false)
	
	
func can_process_input():
	set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if Input.is_action_pressed("player_jump"):
		jumping = true
	else:
		jumping = false
	
	if Input.is_action_just_pressed("player_jump"):
		player.jump_just_pressed.rpc()

	if Input.is_action_just_released("player_jump"):
		player.jump_just_released.rpc()
		
	
	if Input.is_action_pressed("player_run"):
		running = true
	else:
		running = false
