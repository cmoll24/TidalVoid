extends Creature

@onready var thrust_particles = $ThrustParticles

@export var target_altitude = 50

func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thrust(direction, multiplier)
	if direction != Vector2.ZERO:
		thrust_particles.start_thrust(direction, velocity, thrust_power)
	else:
		thrust_particles.stop_thrust()

func creature_movement(_delta):
	if not dominant_body:
		return
	
	var opposite_altitude = get_opposite_altitude(dominant_body)
	
	var move_direction = velocity.normalized()
	
	if opposite_altitude == INF:
		set_thrust(-move_direction)
		return
	
	var altitude_diff = opposite_altitude - target_altitude
	var deadzone = 10.0
	
	if abs(altitude_diff) < deadzone:
		set_thrust(Vector2.ZERO)
	elif altitude_diff < 0:
		set_thrust(move_direction)
	else:
		set_thrust(-move_direction)
