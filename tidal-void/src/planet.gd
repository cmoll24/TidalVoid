extends RigidBody2D

@export var orbit_center_marker : StaticBody2D
var orbit_center : Vector2
@export var source_mass : float = 1000

func _ready() -> void:
	orbit_center = orbit_center_marker.position

func _physics_process(delta: float) -> void:
	var r_hat : Vector2 = global_position.direction_to(orbit_center)
	var r_squared : float = global_position.distance_squared_to(orbit_center)
	
	var g_mag = (1000 * source_mass) / r_squared
	
	#var force_net : Vector2 = mass * g_mag * r_hat
	
	var a_rad : float = pow(linear_velocity.length(), 2) / sqrt(r_squared)
	
	var force_net : Vector2 = mass * a_rad * r_hat
	
	var tangent = r_hat.rotated(-90)
	apply_central_force(1000 * tangent)
	
	apply_central_force(1.051 * force_net)
