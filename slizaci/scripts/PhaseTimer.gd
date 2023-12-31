extends Label

var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $/root/Main/Game/PhaseTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		text = str(snapped(timer.time_left,0.01))
