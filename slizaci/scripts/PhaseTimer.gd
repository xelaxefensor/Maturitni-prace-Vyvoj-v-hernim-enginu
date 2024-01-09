extends Label

var timer
@export var phase_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $/root/Main/Game/PhaseTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_visible_in_tree():
		if multiplayer.is_server():
			phase_time = timer.time_left
		
		if MultiplayerManager.is_online:
			text = str(snapped(phase_time,0.01))
