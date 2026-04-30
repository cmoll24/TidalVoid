extends PlayerPawn
class_name CreatureCarrier

@onready var player_sprite : Sprite2D = $PlayerSprite

@onready var head_lights : PointLight2D = $HeadLights

@onready var planet_thrust_particles : ThrustParticles = $ThrustParticles2

#ship_clearance is the length of ship
@export var ship_clearance : float = 160.0

@onready var bubble : Bubble = $Bubble

### instantaneous velocity change to creatures in the carrier when the bubble is deactivated
@export var bubble_push : float = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	player_sprite.visible = false
	head_lights.enabled = false
	
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	#Thruster behavior when off of the ground
	if direction != Vector2.ZERO:
		super.set_thrust(Vector2.from_angle(global_rotation), multiplier)
		target_rotation = direction.angle();
		thrust_particles.start_thrust(Vector2.ZERO, velocity, thrust_power)
	else:
		super.set_thrust(Vector2.ZERO, multiplier)
		thrust_particles.stop_thrust()
		
func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	##check for dismount
	if controller and Input.is_action_just_pressed("jump"):
		#if we jump, dismount and switch to the player
		var spawn_pos :Vector2 = global_position + (Vector2.from_angle(global_rotation)*50)
		#spawn the player
		var player_scene  = preload("res://src/player/player.tscn")
		var player :PlayerPawn = player_scene.instantiate()
		get_tree().get_root().add_child(player)
		player.global_position = spawn_pos
		#possess the player
		controller.call_deferred('possess_pawn',player)
	
	if dominant_body:
		## ensure we cannot get too close to a planet so as to be unable to leave
		var dist_sq : float = global_position.distance_squared_to(dominant_body.global_position)
		var thrust_output = thrust_power * thrust_multiplier * 0.8 #little wiggle room
		
		#The closest distance that the ship can be to any planet
		var minimum_clearance_dist : float = ship_clearance + dominant_body.collision_radius
		
		if ((dominant_body.mass / dist_sq) > thrust_output) or (dist_sq < minimum_clearance_dist**2):
			## if we are too close, push back to the edge
			var dir :Vector2 = (global_position-dominant_body.global_position).normalized()
			var min_dist = max(sqrt(dominant_body.mass/thrust_output), minimum_clearance_dist)
			
			global_position = dominant_body.global_position + dir * min_dist
			
			#Cancel inward radial velocity
			var radial_speed = velocity.dot(-dir)
			if radial_speed > 0:
				planet_thrust_particles.start_thrust(dir, velocity, 40)
				velocity += 1.1 * dir * radial_speed
		else:
			planet_thrust_particles.stop_thrust()
	
		
func start_possess(player_controller :PlayerController) -> void:
	super.start_possess(player_controller)
	player_sprite.visible = true
	head_lights.enabled = true
	
func stop_possess() -> void:
	super.stop_possess()
	player_sprite.visible = false
	head_lights.enabled = false
	
func action_use() -> void:
	bubble.toggle_bubble()
	
	#upon disabling the bubble, push all creatures in it away from the vehicle
	if(!bubble.b_bubble_enabled):
		var space_state = get_world_2d().direct_space_state
		
		var params : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
		params.shape = bubble.CollisionShape.shape
		params.transform = transform
		params.collision_mask = 2
		
		var results : Array[Dictionary] = space_state.intersect_shape(params,16)
		
		for result in results:
			var collider = result["collider"]
			if(collider is Creature):
				collider.velocity += Vector2.from_angle(global_rotation)*bubble_push
		
