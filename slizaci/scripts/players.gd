extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func clear_players():
	var players = self
	for c in players.get_children():
		c.queue_free()
		

func spawn_player():
