extends Creature
class_name MovingCreature


@onready var thrust_particles = $ThrustParticles

@export var target_altitude_sqr = 3600
	

func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thrust(direction, multiplier)
	if direction != Vector2.ZERO:
		thrust_particles.start_thrust(direction, velocity, thrust_power)
	else:
		thrust_particles.stop_thrust()

func creature_movement(_delta):
	if not dominant_body:
		return
	
	var altitude_sqr = get_square_altitude(dominant_body)
	
	var move_dir = (dominant_body.global_position - global_position)
	# move dir is tangent to gravity
	move_dir = Vector2(move_dir.y,-move_dir.x).normalized()
	
	#ensure it works with current velocity
	if(move_dir.dot(velocity) < -1):
		move_dir = - move_dir
	
	var velocity_deviation = (
		move_dir - velocity.normalized())
		
	var acceptable_deviation = 0.1;
	
	if(velocity_deviation.length_squared() < acceptable_deviation):
		velocity_deviation =Vector2.ZERO
	var altitude_diff = altitude_sqr - target_altitude_sqr
	var deadzone = 15
	
	if(get_square_altitude(dominant_body) > dominant_body.pull_radius ** 2):
		set_thrust(dominant_body.global_position - global_position)
		return
	
	var min_velo = 40;
	
	if(move_dir.dot(velocity) < min_velo):
		set_thrust(move_dir)
		return
	
	if abs(altitude_diff) < deadzone:
		set_thrust(velocity_deviation)
	elif altitude_diff < 0:
		set_thrust(move_dir + velocity_deviation)
	else:
		set_thrust(-move_dir + velocity_deviation)
		
