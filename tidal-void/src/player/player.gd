extends PlayerPawn
class_name Player



#@export var jump_power : float = 200.0
@export var walk_speed : float = 620.0

@export var min_jump_power : float = 10.0
@export var max_jump_power : float = 350.0

var walking_on_ground : bool = false
var is_charging_jump : bool = false
var jump_charge_ratio : float = 0.0
var jump_charge_speed : float = 0.005
var jump_escape_speed : float = 0.0

####################################################### used for the creature holding mechanic
### the velocity applied to things the player throws
@export var throw_velocity : float = 75
### the amount of time a creature is stunned for after holding
@export var hold_stun_time : float = 1
var held_creature : Creature = null

#########################################################
#the player can interact with things in this area
@onready var interact_area : Area2D = $InteractArea

var interact_dir : Vector2 = Vector2.ZERO

var interact_source : InteractSource = null

#This here is for player ability, the idea is to give the player
#a propulsion or after burner in case the player leaves orbit
#The max can be changed to whatever works but once the countdown hits 0,
#it won't be returned till after the player redocks with their ship
var propulsion_max : int = 3
var propulsions_left : int = 3
@export var propulsion_power : float = 300.0

var max_jump_angle : float = PI/2.5

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	super._ready()
	if self.is_in_group("player"):
		print("in player")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	player_movement(delta)
	update_interact_source()

func player_movement(delta : float) -> void:
	if b_is_grounded && walking_on_ground:
		#Exit Condition
		if(velocity.dot(grounded_normal) < -1):
			walking_on_ground = false
			grounded_buffer -= 1
		
		#Handle Jumping
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			b_prediction_velo_is_real = false;
			jump_charge_ratio = 0.5
			jump_escape_speed = escape_speed(grounded_body, global_position)

		if is_charging_jump and Input.is_action_pressed("jump"):
			prediction_velocity = get_jump_vector().limit_length(max_velocity);

		elif is_charging_jump: #no longer detects if the input was just released, this is so tabbing out can't trap you in jumping
			perform_jump()
			walking_on_ground = false
			b_prediction_velo_is_real = true;
		#Handle walking on ground
		
		#ignore collision with static geometry
		ignore_layer = 1
		#circle implementation
		if(grounded_shape.shape is CircleShape2D):
			var player_loc : Vector2 = global_position - grounded_body.global_position
			var player_loc_len : float = grounded_body.shape.shape.radius + collision_shape.shape.radius - 1
			var player_angle : float = player_loc.angle()
			var new_pos : Vector2
			var horizontal_mov = Input.get_axis("thrust_left", "thrust_right")
			if Input.is_action_pressed("thrust") or Input.is_action_pressed("controller_thrust"):
				#move when thrust is held, mouse version
				var mouse_loc : Vector2 = get_global_mouse_position() - grounded_body.global_position
				var mouse_angle : float = mouse_loc.angle()
				var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
				var final_angle : float = rotate_toward(player_angle,mouse_angle,rot_speed)
				new_pos = (Vector2.from_angle(final_angle)*
				player_loc_len)+ grounded_body.global_position
			elif horizontal_mov != 0:
				#wasd, arrow keys version
				horizontal_mov = 1 if horizontal_mov > 0 else -1 #normalizes it
				var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
				var final_angle : float = rotate_toward(player_angle,
				player_angle + (rot_speed*horizontal_mov),rot_speed)
				new_pos = (Vector2.from_angle(final_angle)*
				player_loc_len)+ grounded_body.global_position
			else:
				new_pos = (Vector2.from_angle(player_angle)*
				player_loc_len)+ grounded_body.global_position
			global_position = new_pos
			
			
		else:
			printerr("Walking on ground only supports circle shapes currently, invalid shape used")
	else:
		b_prediction_velo_is_real = true;
		if(b_is_grounded && !walking_on_ground):
			if(Input.is_action_pressed("grab")) or \
			  (velocity.length_squared() < 1):
				is_charging_jump = false
				walking_on_ground = true
		ignore_layer = 0;
	
			
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	if(!(b_is_grounded && walking_on_ground)):
		#Thruster behavior when off of the ground
		super.set_thrust(direction, multiplier)
		if direction != Vector2.ZERO:
			thrust_particles.start_thrust(direction, velocity, thrust_power)
		else:
			thrust_particles.stop_thrust()
	else:
		thrust_particles.stop_thrust()
		

func get_jump_vector() -> Vector2:
	var up_direction = grounded_normal.normalized()
	
	#the jump angle from the ground normal
	var jump_angle : float = up_direction.angle_to(mouse_direction)
	
	if abs(jump_angle) > max_jump_angle * 1.2:
	#	#instead of clamping the thrust angle, allow the player to cancel jumps by angling it at the planet
		return Vector2.ZERO
	elif abs(jump_angle) > max_jump_angle:
		jump_angle = clampf(jump_angle, -max_jump_angle, max_jump_angle)
		
	var mouse_pos: Vector2 = get_global_mouse_position()
	var start_r: float = global_position.distance_to(dominant_body.global_position)
	var target_r: float = mouse_pos.distance_to(dominant_body.global_position)
	
	if target_r <= start_r:
		return Vector2.ZERO
	
	var mu = dominant_body.mass
	
	#orbital transfer energy
	var jump_power = sqrt(mu * 2.0 * (1.0/start_r - 1.0/target_r))
	
	jump_power = clampf(jump_power, min_jump_power, max_jump_power)

	return jump_power * up_direction.rotated(jump_angle)

func action_use(pressed : bool)  -> void:
	if(pressed):
		if(!interact_source):
			return; ## we need an interact source
			
		var diff : Vector2 = interact_source.global_position - global_position
		var dist : float = diff.length()
		var dir : Vector2 = diff/dist
		
		# perform a raycast to see if we can touch the interact source(plus ensures we get the closest thing distance wise)
			
		var space_state = get_world_2d().direct_space_state
		
		#start at the edge of the player
		var start : Vector2 = global_position +(dir*collision_shape.shape.radius) 
		#end use_distance away in the direction of the mouse
		var end : Vector2 = start + (dir*dist)
		
		
		var query = PhysicsRayQueryParameters2D.create(start, end,2,[self.get_rid()])

		var result = space_state.intersect_ray(query)
		
		if result:
			var source : InteractSource = result.collider.get_node_or_null("InteractSource")
			if(source):
				source.interact()
			if(result.collider is PlayerPawn):
				# if we hit a player pawn, swtich to it
				controller.possess_pawn(result.collider, velocity)
			elif(result.collider is Creature and result.collider.creature_size == Creature.creature_size_type.small):
				# if we hit a small creature, hold it
				held_creature = result.collider
				held_creature.stun_time = hold_stun_time
				held_creature.velocity = velocity
	else:
		if(held_creature and held_creature.stun_time > 0):
			## if holding a stunned creature, attempt a throw
			#first check that the creature is still interactable
			if(held_creature in interact_area.get_overlapping_bodies()):
				#close enough, throw it
				held_creature.add_impulse(mouse_direction*max(throw_velocity,gravity_force.length()))
				held_creature.stun_time = hold_stun_time
			
		held_creature = null
		
func update_interact_source() -> void:
	# look at all interactable things
	var largest_dot : float = -9999;
	var closest_source : InteractSource = null;
	for thing in interact_area.get_overlapping_bodies():
		var source : InteractSource = thing.get_node_or_null("InteractSource")
		if(!source):
			continue
		### get information on the position and direction
		var diff : Vector2 = thing.global_position - global_position;
		var dist : float = diff.length();
		var dir : Vector2 = diff/dist;
		var dot :  = dir.dot(mouse_direction);
		###update visuals
		source.enable_interact_sprite(-dir)
		source.set_highlight(false)
		### check if this is the closest source
		if(dot > largest_dot):
			largest_dot = dot;
			closest_source = source;
			
	interact_source = closest_source	
		
	if !closest_source:
		return # only continue if there was anything in the interact area
		
	#highlight the closest source
	closest_source.set_highlight(true)
	
	

func start_possess(player_controller : PlayerController, previous_pawn_velocity : Vector2) -> void:
	super.start_possess(player_controller, previous_pawn_velocity)
	#GV.player_reference(self)
	velocity = previous_pawn_velocity

func stop_possess() -> void:
	super.stop_possess()
	### hide interact icons
	for thing in interact_area.get_overlapping_bodies():
		var source : InteractSource = thing.get_node_or_null("InteractSource")
		if(!source):
			continue
		source.disable_interact_sprite()
	### destroy
	queue_free()


func perform_jump():
	if not b_is_grounded:
		return
	
	var jump_vector = get_jump_vector()
	
	if(jump_vector == Vector2.ZERO):
		return
	velocity += jump_vector

	jump_charge_ratio = 0.0

func propulsion_ability():
	if propulsions_left > 0:
		propulsions_left -= 1
		velocity += (propulsion_power * mouse_direction)
		
func reset_abilities():
	propulsions_left = propulsion_max
	
func _input(event: InputEvent) -> void:
	if event.is_action("inc_jump"):
		jump_charge_ratio = clamp(jump_charge_ratio + jump_charge_speed, 0.0, 1.0)
	elif event.is_action("dec_jump"):
		jump_charge_ratio = clamp(jump_charge_ratio - jump_charge_speed, 0.0, 1.0)


func _on_interact_area_body_exited(body: Node2D) -> void:
	var source : InteractSource = body.get_node_or_null("InteractSource")
	if(source):
		source.disable_interact_sprite()
