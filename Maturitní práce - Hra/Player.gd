extends CharacterBody2D


var speed = 10000.0
var jump_velocity = 10000.0
var groundDrag = 10.0
var airDrag = 6.0
var gravDrag = 1.0

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
		velocity.y += gravity * delta * (Input.get_action_strength("move_down")+1)
		if velocity.y > 1:
			velocity.y -= velocity.y * gravDrag * delta * (1.1-Input.get_action_strength("move_down"))
			print(velocity.y)
			
	if is_on_floor():
		coyoteTimer.start()

	if Input.is_action_just_pressed("move_up"):
		upBufferTimer.start()
		
	if (Input.is_action_just_pressed("move_up") or upBufferTimer.get_time_left() != 0) and (is_on_floor() or coyoteTimer.get_time_left() != 0) and not jumping:
		jumping = true
		coyoteTimer.stop()
		upBufferTimer.stop()
		jumpingTimer.start()
		
	if jumping:
		if Input.is_action_just_released("move_up"):
			jumping = false
		
		if jumpingTimer.get_time_left() != 0 and Input.is_action_pressed("move_up"):
			velocity.y -= jump_velocity * delta
		else:
			jumping = false
		

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		if is_on_floor():
			velocity.x += direction * speed * delta
		else:
			velocity.x += direction * speed * delta * 0.5
	
	if velocity.x:
		if is_on_floor():
			velocity.x -= velocity.x * groundDrag * delta
		else:
			velocity.x -= velocity.x * airDrag * delta
	
	move_and_slide()

