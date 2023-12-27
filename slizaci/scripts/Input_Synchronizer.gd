extends MultiplayerSynchronizer

@export var horizontal_direction = Vector2(0.0, 0.0)
@export var jumping = false

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	self.set_multiplayer_authority(player.id)
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	horizontal_direction = Input.get_axis("player_left", "player_right")
	
	if Input.is_action_pressed("player_up"):
		jumping = true
	else:
		jumping = false
	
	if Input.is_action_just_pressed("player_up"):
		player.jump_just_pressed.rpc()

	if Input.is_action_just_released("player_up"):
		player.jump_just_released.rpc()
