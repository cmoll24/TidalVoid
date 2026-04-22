class_name GravitySource
extends StaticBody2D

@onready var pull_radius_circle = $PullRadius
@onready var collision_radius_shape : CollisionShape2D = $CollisionShape2D
@onready var texture_rect : TextureRect = $TextureRect
@onready var shape : CollisionShape2D = $CollisionShape2D

@export var mass : float = 1000.0
const MASS_SCALE = 1000.0 #the masses must be big so this a multipler
var pull_radius : float = 600.0
@export var collision_radius : float = 50.0

@export var no_grav_radius : float = 1.0

@export var negligible_threshold: float = 10.0

func _ready() -> void:
	pull_radius = calculate_pull_radius()
	pull_radius_circle.scale = Vector2(pull_radius, pull_radius) / (pull_radius_circle.size / 2)#because scale is diameter
	pull_radius_circle.position = -Vector2(pull_radius, pull_radius)#/ 2.0
	if(collision_radius_shape):
		var new_shape = CircleShape2D.new()
		new_shape.radius = collision_radius
		collision_radius_shape.shape = new_shape

	texture_rect.scale = Vector2(collision_radius, collision_radius) / 50.0
	texture_rect.position = -Vector2(collision_radius, collision_radius)
	#all gravity sources exist on layer 2
	collision_layer = 2

func calculate_pull_radius() -> float:
	# solve: (mass * MASS_SCALE) / distance^2 = threshold
	# therefore: distance = sqrt((mass * MASS_SCALE) / threshold)
	return sqrt((mass * MASS_SCALE) / negligible_threshold)

func get_gravity_pull(from_positon : Vector2) -> Vector2:
	var offset_distance = global_position - from_positon
	var distance = offset_distance.length()
	
	if distance > pull_radius or distance < no_grav_radius:
		return Vector2.ZERO
	
	#strength = M / R^2
	var strength = (mass * MASS_SCALE) / max(distance**2, 5000.0)
	
	return offset_distance.normalized() * strength
