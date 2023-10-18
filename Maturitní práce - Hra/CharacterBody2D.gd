extends CharacterBody2D


var speed = 1000.0
var maxSpeed = 400.0
var jump_velocity = 10000.0
var groundDrag = 7.0

var jumpingTimer
var upBufferTimer
var coyoteTimer

var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	jumpingTimer = self.get_node("JumpingTimer")
	upBufferTimer = self.get_node("upBufferTimer")
	coyoteTimer = self.get_node("coyoteTimer")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_on_floor():
		coyoteTimer.start()

	if Input.is_action_just_pressed("move_up"):
		upBufferTimer.start()
		
	if (Input.is_action_just_pressed("move_up") or upBufferTimer.get_time_left() != 0) and (is_on_floor() or coyoteTimer != 0):
		jumping = true
		jumpingTimer.start()
		
	if jumping:
		if jumpingTimer.get_time_left() != 0 and Input.is_action_pressed("move_up"):
			velocity.y -= jump_velocity * delta
		else:
			jumping = false
		

	var direction = Input.get_axis("move_left", "move_right")
	if direction and abs(velocity.x) <= maxSpeed:
		if is_on_floor():
			velocity.x += direction * speed * delta
		else:
			velocity.x += direction * speed/2 * delta
	else:
		if is_on_floor():
			velocity.x -= velocity.x * groundDrag * delta
	
	move_and_slide()

