extends CharacterBody2D

@export var id = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func set_id(id):
	self.id = id
	add_to_group("id"+str(id))
	

func _ready():
	if id == multiplayer.get_unique_id():
		$Camera2D.make_current()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
