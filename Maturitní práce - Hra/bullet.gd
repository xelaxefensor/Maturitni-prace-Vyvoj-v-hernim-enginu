extends RigidBody2D

var dmg
var startForce

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(startForce,Vector2(0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func innitialize(position, startForce):
	self.position=position
	self.startForce = startForce


func _on_despawn_timer_timeout():
	self.queue_free()
