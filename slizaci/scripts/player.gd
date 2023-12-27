extends CharacterBody2D

@export var id := 1 :
	set(player_id):
		id = player_id
		add_to_group("id"+str(id))
		# Give authority over the player input to the appropriate peer.
		$InputSynchronizer.set_multiplayer_authority(id)

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
var jump_buffer = false
var is_on_coyote_floor = false
var can_still_jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

	
func _ready():
	if id == multiplayer.get_unique_id():
		$Camera2D.make_current()
		
	jumpingTimer = self.get_node("JumpingTimer")
	upBufferTimer = self.get_node("UpBufferTimer")
	coyoteTimer = self.get_node("CoyoteTimer")
	
	jumpingTimer.set_wait_time(jumpingTime)
	upBufferTimer.set_wait_time(upBufferTime)
	coyoteTimer.set_wait_time(coyoteTime)
	
	set_physics_process(multiplayer.is_server())
	

func player_is_on_floor():
	is_on_coyote_floor = true
	coyoteTimer.start()


@rpc("any_peer", "call_local", "reliable", 2)
func jump_just_pressed():
	upBufferTimer.start()
	jump_buffer = true
	start_jumping()


func _on_up_buffer_timer_timeout():
	jump_buffer = false


func _on_coyote_timer_timeout():
	is_on_coyote_floor = false


func start_jumping():
	if jump_buffer and !jumping and (is_on_coyote_floor or is_on_floor()):
		jumping = true
		coyoteTimer.stop()
		upBufferTimer.stop()
		jumpingTimer.start()
		jump_buffer = false
		is_on_coyote_floor = false
		can_still_jump = true


@rpc("any_peer", "call_local", "reliable", 2)
func jump_just_released():
	jumping = false
	can_still_jump = false
	

func _on_jumping_timer_timeout():
	can_still_jump = false
	jumping = false


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta# * (Input.get_action_strength("move_down")+1)
		if velocity.y > 0:
			velocity.y -= velocity.y * gravDrag * delta
			
	if is_on_floor():
		player_is_on_floor()
		
	if jumping and can_still_jump and $InputSynchronizer.jumping:
		velocity.y -= jumpVelocity * delta
		
	#var run
	#if Input.is_action_pressed("move_run"):
	#	run = 2.0
	#else:
	#	run = 1.0
	
	var direction = $InputSynchronizer.horizontal_direction
	if direction:
		if is_on_floor():
			velocity.x += direction * speed * delta# * run
		else:
			velocity.x += direction * speed * delta * 0.5# * run
	
	if velocity.x:
		if is_on_floor():
			velocity.x -= velocity.x * groundDrag * delta
		else:
			velocity.x -= velocity.x * airDrag * delta

	
	move_and_slide()



