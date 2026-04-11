
extends DriftBody
class_name Player

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

#@export var jump_power : float = 200.0
@export var walk_speed : float = 20

@export var min_jump_power : float = 50.0
@export var max_jump_power : float = 600.0
@export var max_charge_time : float = 4.0  # seconds to reach full charge

var walking_on_ground : bool = false
var is_charging_jump : bool = false
var jump_charge_time : float = 0.0

var max_jump_angle : float = PI/2.5

var mouse_direction : Vector2

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	super._ready()
	
	thrust_particles.emitting = false

func start_thrust_particles(direction):
	#the particles must have speed scale of 1.0 for this to work
	thrust_particles.speed_scale = 1.0
	
	var exhaust_direction = -direction
	var spread = 0.1 * randf_range(-1, 1)
	
	var exhaust_speed : float = thrust_power * 10
	
	var total_velocity = velocity + exhaust_speed * exhaust_direction.rotated(spread)
	
	var particle_speed = total_velocity.length()
	var particle_direction = total_velocity.normalized()
	
	# must use .rotated(-rotation) so that the direction does not depend on player rotation
	thrust_particles.direction = particle_direction.rotated(-global_rotation)
	thrust_particles.initial_velocity_min = particle_speed * 0.9
	thrust_particles.initial_velocity_max = particle_speed * 1.1
	
	thrust_particles.emitting = true

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if b_is_grounded && walking_on_ground:
		#Exit Condition
		if(velocity.dot(grounded_normal) < -1):
			walking_on_ground = false
			grounded_buffer -= 1
		
		#Handle Jumping
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			b_prediction_velo_is_real = false;
			jump_charge_time = 0.0

		if is_charging_jump and Input.is_action_pressed("jump"):
			jump_charge_time += delta
			jump_charge_time = min(jump_charge_time, max_charge_time)
			prediction_velocity = get_jump_vector();

		elif is_charging_jump: #no longer detects if the input was just released, this is so tabbing out can't trap you in jumping
			perform_jump()
			walking_on_ground = false
			b_prediction_velo_is_real = true;
		#Handle walking on ground
		
		#ignore collision with driftbodies
		ignore_layer = 2
		#circle implementation
		if(grounded_shape.shape is CircleShape2D):
			var player_loc : Vector2 = global_position - grounded_body.global_position
			var player_loc_len : float = grounded_body.shape.shape.radius + collision_shape.shape.radius - 1
			var player_angle : float = player_loc.angle()
			var new_pos : Vector2
			if Input.is_action_pressed("thrust"):
				#move when thrust is held
				var mouse_loc : Vector2 = get_global_mouse_position()- grounded_body.global_position
				var mouse_angle : float = mouse_loc.angle()
				var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
				var final_angle : float = rotate_toward(player_angle,mouse_angle,rot_speed)
				new_pos = (Vector2.from_angle(final_angle)*
				player_loc_len)+ grounded_body.global_position
			else:
				new_pos = (Vector2.from_angle(player_angle)*
				player_loc_len)+ grounded_body.global_position
			global_position = new_pos
			
			
		else:
			printerr("Walking on ground only support circle shapes currently, invalid shape used")
	else:
		b_prediction_velo_is_real = true;
		if(b_is_grounded && !walking_on_ground):
			if(Input.is_action_pressed("jump")):
				is_charging_jump = false
				walking_on_ground = true
		ignore_layer = 0;
				
	#Rotate the player
	var new_angle = (gravity_force.angle() - PI/2)
	var rot_spd = PI * delta
	rotation = rotate_toward(rotation,new_angle,rot_spd)
	
			
func set_thurst(direction : Vector2, multiplier : float = 1.0) -> void:
	if(!(b_is_grounded && walking_on_ground)):
		#Thruster behavior when off of the ground
		super.set_thurst(direction, multiplier)
		if direction != Vector2.ZERO:
			start_thrust_particles(direction)
		else:
			thrust_particles.emitting = false
	else:
		thrust_particles.emitting = false
		

func get_jump_vector() -> Vector2:
	var charge_ratio = jump_charge_time / max_charge_time
	var curved_ratio = pow(charge_ratio, 0.3) #I like the feel of this better
	var power =  lerp(min_jump_power, max_jump_power, curved_ratio)
	
	var up_direction = grounded_normal.normalized()
	
	if mouse_direction == Vector2.ZERO:
		return power * up_direction
	
	var angle_to_thrust = up_direction.angle_to(mouse_direction)
	
	var jump_angle = clampf(angle_to_thrust, -max_jump_angle, max_jump_angle)
	
	return power * up_direction.rotated(jump_angle)


func perform_jump():
	if not b_is_grounded:
		return

	var jump_vector = get_jump_vector()

	velocity += jump_vector

	jump_charge_time = 0.0
