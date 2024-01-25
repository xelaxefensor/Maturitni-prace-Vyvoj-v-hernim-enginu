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

@export var jumpingTime:float = 0.076
var upBufferTimer
@export var upBufferTime:float = 0.073
var coyoteTimer
@export var coyoteTime:float = 0.193

var jumping = false
var jump_buffer = false
var is_on_coyote_floor = false

var input_jump_pressed = false
var jumping_timer = 0.0

var running = false
var move_direction = Vector2(0, 0)
var mouse_from_centre_pixels = Vector2(0, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 1200

	
func _ready():
	if id == multiplayer.get_unique_id():
		$PlayerCamera.make_current()
		
	upBufferTimer = self.get_node("UpBufferTimer")
	coyoteTimer = self.get_node("CoyoteTimer")
	
	upBufferTimer.set_wait_time(upBufferTime)
	coyoteTimer.set_wait_time(coyoteTime)
	
	#set_physics_process(multiplayer.is_server())
	

func player_is_on_floor():
	if !jumping:
		is_on_coyote_floor = true
		coyoteTimer.start()


@rpc("any_peer", "call_local", "unreliable", 2)
func jump_just_pressed():
	upBufferTimer.start()
	jump_buffer = true
	input_jump_pressed = true
	start_jumping()


func _on_up_buffer_timer_timeout():
	jump_buffer = false


func _on_coyote_timer_timeout():
	is_on_coyote_floor = false


func start_jumping():
	if jump_buffer and !jumping and (is_on_coyote_floor or is_on_floor()):
		coyoteTimer.stop()
		upBufferTimer.stop()
		jump_buffer = false
		is_on_coyote_floor = false
		jumping = true
			

@rpc("any_peer", "call_local", "unreliable", 2)
func jump_just_released():
	jumping = false
	input_jump_pressed = false
	

func _on_jumping_timer_timeout():
	jumping = false


func _process(delta):
	move_direction = $InputSynchronizer.direction
	running = $InputSynchronizer.running
	mouse_from_centre_pixels = $InputSynchronizer.mouse_from_centre
	
	
	if move_direction.x:
		%AnimatedSprite2D.play("run")
		if move_direction.x < 0:
			%AnimatedSprite2D.flip_h = true
		if move_direction.x > 0:
			%AnimatedSprite2D.flip_h = false
	else:
		%AnimatedSprite2D.play("idle")
	
	if $InputSynchronizer.running:
		%AnimatedSprite2D.speed_scale = 2
	else:
		%AnimatedSprite2D.speed_scale = 1


func _physics_process(delta):
	if not is_on_floor():
		if move_direction.y > 0:
			velocity.y += gravity * delta * (move_direction.y+1)
		else:
			velocity.y += gravity * delta
			
		if velocity.y > 0:
			velocity.y -= velocity.y * gravDrag * delta
			
	if is_on_floor():
		player_is_on_floor()
		
		
	if jumping_timer >= 0.1:
		jumping = false
		jumping_timer = 0.0
		
	if jumping and input_jump_pressed:
		jumping_timer += delta
		velocity.y -= jumpVelocity * delta

		
	var run
	if running:
		run = 2.0
	else:
		run = 1.0
	
	
	if move_direction.x:
		if is_on_floor():
			velocity.x += move_direction.x * speed * delta * run
		else:
			velocity.x += move_direction.x * speed * delta * 0.5 * run
	
	if velocity.x:
		if is_on_floor():
			velocity.x -= velocity.x * groundDrag * delta
		else:
			velocity.x -= velocity.x * airDrag * delta

	
	move_and_slide()
