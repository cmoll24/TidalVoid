class_name GravitySource
extends StaticBody2D

@onready var pull_radius_circle = $PullRadius

@export var mass : float = 1000.0
const MASS_SCALE = 1000.0 #the masses must be big so this a multipler
var pull_radius : float = 600.0
@export var collision_radius : float = 50.0

@export var no_grav_radius : float = 1.0

@export var negligible_threshold: float = 10.0

func _ready() -> void:
	pull_radius = calculate_pull_radius()
	print(pull_radius)
	pull_radius_circle.scale = Vector2(pull_radius, pull_radius) / 50.0 #because scale is diameter
	pull_radius_circle.position = -Vector2(pull_radius, pull_radius)# / 2.0

func calculate_pull_radius() -> float:
	# solve: (mass * MASS_SCALE) / distance^2 = threshold
	# therefore: distance = sqrt((mass * MASS_SCALE) / threshold)
	return sqrt((mass * MASS_SCALE) / negligible_threshold)

func get_gravity_pull(from_positon : Vector2) -> Vector2:
	var offset_distance = global_position - from_positon
	var distance = offset_distance.length()
	
	if distance > pull_radius or distance < no_grav_radius:
		return Vector2.ZERO
	
	#print(distance, " - ", distance**2, " ++ ", max(distance**2, 3000.0))
	var strength = (mass * MASS_SCALE) / max(distance**2, 5000.0)
	#print(strength)
	
	return offset_distance.normalized() * strength
