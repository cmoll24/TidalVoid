class_name ThrustParticles
extends CPUParticles2D

func _ready() -> void:
	emitting = false

func start_thrust(thrust_direction, velocity, thrust_power):
	#the particles must have speed scale of 1.0 for this to work
	speed_scale = 1.0
	
	var exhaust_direction = -thrust_direction
	var spread = 0.1 * randf_range(-1, 1)
	
	var exhaust_speed : float = 100 + thrust_power
	
	var total_velocity = velocity + exhaust_speed * exhaust_direction.rotated(spread)
	
	var particle_speed = total_velocity.length()
	var particle_direction = total_velocity.normalized()
	
	# must use .rotated(-rotation) so that the direction does not depend on player rotation
	direction = particle_direction.rotated(-global_rotation)
	initial_velocity_min = particle_speed * 0.9
	initial_velocity_max = particle_speed * 1.1
	
	emitting = true

func stop_thrust():
	emitting = false
