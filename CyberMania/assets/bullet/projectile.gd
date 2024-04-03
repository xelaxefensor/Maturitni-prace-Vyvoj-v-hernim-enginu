extends RigidBody2D

@export var damage = 10
@export var start_force:float
@export var time_to_live = 5.0

# these are configured as "Watch" in the MultiplayerSynchronizer
@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

@export var hurt_area: Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if not multiplayer.is_server():
		position = replicated_position
		rotation = replicated_rotation
		linear_velocity = replicated_linear_velocity
		angular_velocity = replicated_angular_velocity
	
	apply_central_impulse(Vector2(cos(rotation),sin(rotation))*start_force)
	
	if multiplayer.is_server():
		await get_tree().create_timer(time_to_live).timeout
		self.queue_free()
	

func _integrate_forces(_state : PhysicsDirectBodyState2D) -> void:
  # Synchronizing the physics values directly causes problems since you can't
  # directly update physics values outside of _integrate_forces. This is
  # an attempt to resolve that problem while still being able to use
  # MultiplayerSynchronizer to replicate the values.

  # The object owner makes shadow copies of the physics values.
  # These shadow copies get synchronized by the MultiplyaerSynchronizer
  # The client copies the synchronized shadow values into the 
  # actual physics properties inside integrate_forces
	if multiplayer.has_multiplayer_peer():
		if multiplayer.is_server():
			replicated_position = position
			replicated_rotation = rotation
			replicated_linear_velocity = linear_velocity
			replicated_angular_velocity = angular_velocity
		else:
			position = replicated_position
			rotation = replicated_rotation
			linear_velocity = replicated_linear_velocity
			angular_velocity = replicated_angular_velocity


func innitialize(position, start_force, rotation, player_id, team_id):
	self.global_position = position
	self.start_force = start_force
	self.rotation = rotation
	
	replicated_position = position
	replicated_rotation = rotation
	
	add_to_group("player_id_"+str(player_id))
	add_to_group("team_"+str(team_id))
	
	hurt_area.player_id = player_id
	hurt_area.team_id = team_id


func _on_body_entered(body):
	self.queue_free()
