extends PlayerPawn
class_name CreatureCarrier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	#Thruster behavior when off of the ground
	if direction != Vector2.ZERO:
		super.set_thrust(Vector2.from_angle(global_rotation), multiplier)
		target_rotation = direction.angle();
		thrust_particles.start_thrust(Vector2.ZERO, velocity, thrust_power)
	else:
		super.set_thrust(Vector2.ZERO, multiplier)
		thrust_particles.stop_thrust()
