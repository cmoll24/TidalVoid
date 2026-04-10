
extends DriftBody
class_name Player

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

#@export var jump_power : float = 200.0
@export var walk_speed : float = 20

@export var min_jump_power : float = 50.0
@export var max_jump_power : float = 600.0
@export var max_charge_time : float = 3.0  # seconds to reach full charge

var walking_on_ground : bool = false
var is_charging_jump : bool = false
var jump_charge_time : float = 0.0

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	super._ready()
	
	thrust_particles.emitting = false

func start_thrust_particles(direction):
	#the particles must have speed scale of 1.0 for this to work
	thrust_particles.speed_scale = 1.0
	
	var exhaust_direction = -direction
	var spread = 0.1 * randf_range(-1, 1)
	
	var exhaust_speed : float = thrust_power * 12
	
	var total_velocity = exhaust_speed * exhaust_direction.rotated(spread)
	
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
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			b_prediction_velo_is_real = false;
			jump_charge_time = 0.0

		if is_charging_jump and Input.is_action_pressed("jump"):
			jump_charge_time += delta
			jump_charge_time = min(jump_charge_time, max_charge_time)
			var charge_ratio = jump_charge_time / max_charge_time
			var power : float= lerp(min_jump_power, max_jump_power, charge_ratio)
			prediction_velocity = velocity + (power * grounded_normal);

		elif is_charging_jump: #no longer detects if the input was just released, this is so tabbing out can't trap you in jumping
			perform_jump()
			b_prediction_velo_is_real = true;
		print("walking on ground")
		print(walking_on_ground)
		print("grounded")
		print(b_is_grounded)	
		#circle implementation
		if(grounded_shape.shape is CircleShape2D):
			var player_loc : Vector2 = global_position - grounded_body.global_position
			var player_loc_len : float = player_loc.length()
			var mouse_loc : Vector2 = get_global_mouse_position()- grounded_body.global_position
			var player_angle : float = player_loc.angle()
			var mouse_angle : float = mouse_loc.angle()
			var rot_diff = mouse_angle - player_angle
			var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
			var final_angle : float = player_angle
			if(abs(rot_diff) < rot_speed):
				final_angle = mouse_angle
			else:
				final_angle += rot_speed if (rot_diff > 0 && rot_diff < PI) else -rot_speed
			var new_pos = (Vector2.from_angle(final_angle)*
			player_loc_len)+ grounded_body.global_position
			print(grounded_body.global_position)
			global_position = new_pos
			
			
		else:
			printerr("Walking on ground only support circle shapes currently, invalid shape used")
	else:
		b_prediction_velo_is_real = true;
		if(b_is_grounded && !walking_on_ground):
			if(Input.is_action_pressed("jump")):
				walking_on_ground = true
				
	#Rotate the player
	if(abs(rotation) >= 2*PI):
		rotation = (fmod(rotation/PI,2)*PI)
	var new_angle = (gravity_force.angle() - PI/2) 
	if(abs(new_angle) >= 2*PI):
		new_angle = (fmod(new_angle/PI,2)*PI)
	var diff = new_angle - rotation
	var rot_spd = PI * delta
	if(abs(diff) < rot_spd):
		rotation = new_angle
	else:
		rotation += rot_spd if diff > 0 else -rot_spd
	
			
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
		

#func jump():
#	if not is_grounded:
#		return
#	apply_central_impulse(jump_power * surface_normal)

func perform_jump():
	if not b_is_grounded:
		return

	is_charging_jump = false

	var charge_ratio = jump_charge_time / max_charge_time

	var final_power = lerp(min_jump_power, max_jump_power, charge_ratio)

	velocity += final_power * grounded_normal

	jump_charge_time = 0.0
