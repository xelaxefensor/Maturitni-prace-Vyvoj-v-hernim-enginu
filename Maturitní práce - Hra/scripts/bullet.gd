extends RigidBody2D

var dmg
var startForce

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(Vector2(cos(rotation),sin(rotation))*startForce)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func innitialize(position, startForce, rotation):
	self.position = position
	self.startForce = startForce
	self.rotation = rotation


func _on_despawn_timer_timeout():
	self.queue_free()
