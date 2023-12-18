extends CharacterBody2D


@export var speed:float = 6000.0
@export var jumpVelocity:float = 10000.0

@export var groundDrag:float = 10.0
@export var airDrag:float = 4.0
@export var gravDrag:float = 1.0

var jumpingTimer
@export var jumpingTime:float = 0.076
var upBufferTimer
@export var upBufferTime:float = 0.073
var coyoteTimer
@export var coyoteTime:float = 0.193

var jumping = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	jumpingTimer = self.get_node("JumpingTimer")
	upBufferTimer = self.get_node("UpBufferTimer")
	coyoteTimer = self.get_node("CoyoteTimer")
	
	jumpingTimer.set_wait_time(jumpingTime)
	upBufferTimer.set_wait_time(upBufferTime)
	coyoteTimer.set_wait_time(coyoteTime)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * (Input.get_action_strength("move_down")+1)
		if velocity.y > 0:
			velocity.y -= velocity.y * gravDrag * delta
			
			
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
			velocity.y -= jumpVelocity * delta
		else:
			jumping = false
		
	var run
	if Input.is_action_pressed("move_run"):
		run = 2.0
	else:
		run = 1.0
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		if is_on_floor():
			velocity.x += direction * speed * delta * run
		else:
			velocity.x += direction * speed * delta * 0.5 * run
	
	if velocity.x:
		if is_on_floor():
			velocity.x -= velocity.x * groundDrag * delta
		else:
			velocity.x -= velocity.x * airDrag * delta

	
	move_and_slide()

