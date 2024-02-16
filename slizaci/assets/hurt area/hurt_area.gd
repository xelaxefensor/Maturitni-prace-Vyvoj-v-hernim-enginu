extends Area2D

@export var damage = {"damage" = 10, "player_id" = 0, "team_id" = 0}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func do_damage():
	return damage
