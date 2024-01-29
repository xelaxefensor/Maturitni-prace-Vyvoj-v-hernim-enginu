extends RigidBody2D

var dmg
var startForce
@export var time_to_live = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(Vector2(cos(rotation),sin(rotation))*startForce)
	
	await get_tree().create_timer(time_to_live).timeout
	self.queue_free()


func innitialize(position, startForce, rotation):
	self.position = position
	self.startForce = startForce
	self.rotation = rotation
