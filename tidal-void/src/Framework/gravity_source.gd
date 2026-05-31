class_name GravitySource
extends StaticBody2D

@onready var pull_radius_circle = $PullRadius
@onready var collision_radius_shape : CollisionShape2D = $CollisionShape2D
@onready var shape : CollisionShape2D = $CollisionShape2D

@export var mass : float = 1000.0

const MASS_SCALE = 1000.0 #the masses must be big so this a multipler

var pull_radius : float = 600.0

@export var collision_radius : float = 50.0

@export var no_grav_radius : float = 1.0

@export var negligible_threshold: float = 10.0

### make sure to update velocity here if you make a moving grav source
var velocity : Vector2 = Vector2.ZERO

var game_manager : GameManager

func _ready() -> void:
	#get the game manager
	game_manager = get_tree().get_first_node_in_group('game_managers')
	#register with the game manager
	game_manager.register_gravity_source(self)
	#initialize values
	mass = mass*MASS_SCALE
	pull_radius = calculate_pull_radius()
	#set the pull radius
	pull_radius_circle.scale = Vector2(pull_radius, pull_radius) / (pull_radius_circle.size / 2)#because scale is diameter
	pull_radius_circle.position = -Vector2(pull_radius, pull_radius)#/ 2.0
	#correct the collision radius if it is off
	if(collision_radius_shape &&
	 collision_radius_shape.shape.radius - collision_radius < 0.7):
		var new_shape = CircleShape2D.new()
		new_shape.radius = collision_radius
		collision_radius_shape.shape = new_shape
	#all gravity sources exist on layer 1
	collision_layer = 1

func calculate_pull_radius() -> float:
	# solve: (mass) / distance^2 = threshold
	# therefore: distance = sqrt((mass) / threshold)
	return sqrt((mass) / negligible_threshold)

func get_gravity_pull(from_positon : Vector2) -> Vector2:
	#First perform bounds check
	if(!_in_bounds(from_positon)):
		return Vector2.ZERO
		
	var offset_distance = global_position - from_positon
	#now just squared given that no sqrt was ever necessary
	var distance_sqr = offset_distance.length_squared()
	
	if distance_sqr > pull_radius**2 or distance_sqr < no_grav_radius: #no grav radius is just 1 by default, so the square is skipped
		return Vector2.ZERO
	
	#strength = M / R^2
	var strength = (mass) / max(distance_sqr, 5000.0)
	
	return offset_distance.normalized() * strength

func unload():
	#unregister the gravity source
	game_manager.unregister_gravity_source(self)
	
func _in_bounds(pos : Vector2) -> bool:
	#do basic rectangle bounds check
	if(pos.x < global_position.x - pull_radius):
		return false
	if(pos.x > global_position.x + pull_radius):
		return false
	if(pos.y < global_position.y - pull_radius):
		return false
	if(pos.y > global_position.y + pull_radius):
		return false
		
	#if we are between all the sides, we are in the rectangle
	return true
