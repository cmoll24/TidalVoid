class_name Player
extends DriftBody

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

@export var jump_power : float = 150.0

func _ready() -> void:
	super._ready()
	
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

func set_thurst(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thurst(direction, multiplier)
	
	if direction != Vector2.ZERO:
		start_thrust_particles(direction)
	else:
		thrust_particles.emitting = false

func jump(direction : Vector2):
	apply_central_impulse(jump_power * direction)
