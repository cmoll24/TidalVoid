class_name Player
extends DriftBody

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

@export var jump_power : float = 200.0

var is_grounded : bool = false
var grounded_body : GravitySource
var surface_normal : Vector2 = Vector2.ZERO

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

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	check_grounded(state)

func check_grounded(state: PhysicsDirectBodyState2D):
	#This required contact_moniter = true and max_contact_reported >= 1
	
	is_grounded = false
	grounded_body = null
	
	for i in state.get_contact_count():
		var collider = state.get_contact_collider_object(i)
		if collider is GravitySource:
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
	
	if direction != Vector2.ZERO:
		start_thrust_particles(direction)
	else:
		thrust_particles.emitting = false

func jump():
	if not is_grounded:
		return
	apply_central_impulse(jump_power * surface_normal)
