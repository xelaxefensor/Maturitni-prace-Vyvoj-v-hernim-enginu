extends CharacterBody2D

@export var player_id := 1 :
	set(id):
		player_id = id
		add_to_group("player_id_"+str(id))
		# Give authority over the player input to the appropriate peer.
		$InputSynchronizer.set_multiplayer_authority(id)
		
var team_id := 1

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

@export var hit_area: Area2D

var is_dead = false
	
func _ready():
	if player_id == multiplayer.get_unique_id():
		$PlayerCamera.make_current()
		$AudioListener2D.make_current()
		
		change_player_name.rpc(PlayerSettings.player_name, $/root/Main/Game.players[player_id]["team"])


	upBufferTimer = self.get_node("UpBufferTimer")
	coyoteTimer = self.get_node("CoyoteTimer")
	
	upBufferTimer.set_wait_time(upBufferTime)
	coyoteTimer.set_wait_time(coyoteTime)
	
	#set_physics_process(multiplayer.is_server())
	
	if multiplayer.is_server():
		add_to_group("team_"+str($/root/Main/Game.players[player_id]["team"]))
		team_id = $/root/Main/Game.players[player_id]["team"]
		
		#var children = get_children()
		#for c in self.get_children():
		#	c.add_to_group("team_"+str($/root/Main/Game.players[player_id]["team"]))
		#	c.add_to_group("player_id_"+str(player_id))
			
		hit_area.player_id = player_id
		hit_area.team_id = team_id


@rpc("any_peer", "call_local", "reliable")
func change_player_name(name, team):
	$Smoothing2D/PlayerLabel.text = str(name)
	if team == 1:
		var team_label_settings:LabelSettings = load("res://themes_fonts/team1_label_settings.tres")
		$Smoothing2D/PlayerLabel.set_label_settings(team_label_settings)
	if team == 2:
		var team_label_settings:LabelSettings = load("res://themes_fonts/team2_label_settings.tres")
		$Smoothing2D/PlayerLabel.set_label_settings(team_label_settings)
	

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
		
		$JumpVoiceSound.play()
			

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
		if move_direction.x < 0:
			%AnimatedSprite2D.flip_h = true
		if move_direction.x > 0:
			%AnimatedSprite2D.flip_h = false
	
		
	if not is_dead:	
		if is_on_floor():
			if move_direction.x:
				if $InputSynchronizer.running:
					%AnimatedSprite2D.play("run")
				else:
					%AnimatedSprite2D.play("walk")
			else:
				%AnimatedSprite2D.play("idle")	
		else:
			if velocity.y < 0:
				%AnimatedSprite2D.play("jump_start")
			else:
				%AnimatedSprite2D.play("jump_end")
				


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


func _on_animated_sprite_2d_frame_changed():
	if move_direction.x and is_on_floor() and not is_dead:
		if $Smoothing2D/AnimatedSprite2D.frame == 6:
			$StepSound1.play()
		if $Smoothing2D/AnimatedSprite2D.frame == 2:
			$StepSound2.play()
		if $Smoothing2D/AnimatedSprite2D.frame == 5:
			$StepSound3.play()


func _on_health_health_zero():
	on_dead.rpc()
	
	
@rpc("any_peer", "call_local")
func on_dead():
	is_dead = true
	$PlayerMouseCentre/Arm.visible = false
	$Weapons.visible = false
	
	$InputSynchronizer.cannot_process_input()
			
	get_node("DeathSound").play()
	get_node("Smoothing2D/AnimatedSprite2D").play("death")
