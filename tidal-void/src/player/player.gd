class_name Player
extends DriftBody

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

#@export var jump_power : float = 200.0
@export var walk_speed : float = 100.0

@export var min_jump_power : float = 50.0
@export var max_jump_power : float = 330.0
@export var max_charge_time : float = 5.0  # seconds to reach full charge

var is_grounded : bool = false
var grounded_body : GravitySource
var surface_normal : Vector2 = Vector2.ZERO
var is_charging_jump : bool = false
var jump_charge_time : float = 0.0
var max_jump_angle : float = PI/2.5

var mouse_direction : Vector2

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 1
	
	thrust_particles.emitting = false

func start_thrust_particles(direction):
	#the particles must have speed scale of 1.0 for this to work
	thrust_particles.speed_scale = 1.0
	
	var exhaust_direction = -direction
	var spread = 0.1 * randf_range(-1, 1)
	
	var exhaust_speed : float = thrust_power * 10
	
	var total_velocity = linear_velocity + exhaust_speed * exhaust_direction.rotated(spread)
	
	var particle_speed = total_velocity.length()
	var particle_direction = total_velocity.normalized()
	
	# must use .rotated(-rotation) so that the direction does not depend on player rotation
	thrust_particles.direction = particle_direction.rotated(-global_rotation)
	thrust_particles.initial_velocity_min = particle_speed * 0.9
	thrust_particles.initial_velocity_max = particle_speed * 1.1
	
	thrust_particles.emitting = true

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if is_grounded:
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			jump_charge_time = 0.0

		if is_charging_jump and Input.is_action_pressed("jump"):
			jump_charge_time += delta
			jump_charge_time = min(jump_charge_time, max_charge_time)

		if is_charging_jump and Input.is_action_just_released("jump"):
			perform_jump()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	check_grounded(state)
	if is_grounded:
		handle_ground_movement(state)

func check_grounded(state: PhysicsDirectBodyState2D):
	#This required contact_moniter = true and max_contact_reported >= 1
	
	is_grounded = false
	grounded_body = null
	
	for i in state.get_contact_count():
		var collider = state.get_contact_collider_object(i)
		if collider is GravitySource: #this means it currently ignores dirftPlanets
			is_grounded = true
			grounded_body = collider
			surface_normal = state.get_contact_local_normal(i)
			
			#surface friction
			#var gravity = collider.get_gravity_pull(global_position).length()
			#var friction_amount = mass * gravity * surface_friction_coef
			var friction_amount = 0.1
			state.linear_velocity *= 1.0 - (friction_amount * state.step)
			
			return #Currently we stop after finding a first collision, idk what we sohuld do if there are several

func set_thurst(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thurst(direction, multiplier)
	
	if direction != Vector2.ZERO and not is_grounded:
		start_thrust_particles(direction)
	else:
		thrust_particles.emitting = false

#func jump():
#	if not is_grounded:
#		return
#	apply_central_impulse(jump_power * surface_normal)

func get_jump_vector() -> Vector2:
	var charge_ratio = jump_charge_time / max_charge_time
	var curved_ratio = pow(charge_ratio, 0.3) #I like the feel of this better
	var power =  lerp(min_jump_power, max_jump_power, curved_ratio)
	
	var up_direction = surface_normal.normalized()
	
	if mouse_direction == Vector2.ZERO:
		return power * up_direction
	
	var angle_to_thrust = up_direction.angle_to(mouse_direction)
	
	var jump_angle = clampf(angle_to_thrust, -max_jump_angle, max_jump_angle)
	
	return power * up_direction.rotated(jump_angle)

func perform_jump():
	if not is_grounded:
		return

	is_charging_jump = false
	
	var jump_vector = get_jump_vector()

	apply_central_impulse(jump_vector)

	jump_charge_time = 0.0

func handle_ground_movement(state: PhysicsDirectBodyState2D):
	if grounded_body == null:
		return

	var up_dir = surface_normal.normalized()
	rotation = up_dir.angle() + PI/2
	state.angular_velocity = 0
	
	if thrust_direction == Vector2.ZERO:
		return

	#the vector parralel to up_dir
	var tangent = Vector2(-up_dir.y, up_dir.x)

	#var input_dir = 0
	#if Input.is_action_pressed("thrust_left"):
	#	input_dir -= 1
	#if Input.is_action_pressed("thrust_right"):
	#	input_dir += 1
	var input_dir = thrust_direction.dot(tangent)

	var target_velocity = tangent * input_dir * walk_speed

	var radial_velocity = up_dir * state.linear_velocity.dot(up_dir)
	state.linear_velocity = radial_velocity + target_velocity
