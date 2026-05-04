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

var velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	mass = mass*MASS_SCALE
	pull_radius = calculate_pull_radius()
	pull_radius_circle.scale = Vector2(pull_radius, pull_radius) / (pull_radius_circle.size / 2)#because scale is diameter
	pull_radius_circle.position = -Vector2(pull_radius, pull_radius)#/ 2.0
	if(collision_radius_shape):
		var new_shape = CircleShape2D.new()
		new_shape.radius = collision_radius
		collision_radius_shape.shape = new_shape

	if texture_rect:
		texture_rect.scale = Vector2(collision_radius, collision_radius) / 50.0
		texture_rect.position = -Vector2(collision_radius, collision_radius)
	#all gravity sources exist on layer 1
	collision_layer = 1

func calculate_pull_radius() -> float:
	# solve: (mass) / distance^2 = threshold
	# therefore: distance = sqrt((mass) / threshold)
	return sqrt((mass) / negligible_threshold)

func get_gravity_pull(from_positon : Vector2) -> Vector2:
	var offset_distance = global_position - from_positon
	#now just squared given that no sqrt was ever necessary
	var distance_sqr = offset_distance.length_squared()
	
	if distance_sqr > pull_radius**2 or distance_sqr < no_grav_radius: #no grav radius is just 1 by default, so the square is skipped
		return Vector2.ZERO
	
	#strength = M / R^2
	var strength = (mass) / max(distance_sqr, 5000.0)
	
	return offset_distance.normalized() * strength
