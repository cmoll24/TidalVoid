class_name GravitySource
extends StaticBody2D

@export var mass : float = 1000.0
var MASS_SCALE = 1000.0 #the masses must be big so this a multipler
@export var pull_radius : float = 600.0

@export var no_grav_radius : float = 1.0

var MAX_GRAV_STRENGTH = 400.0

func get_gravity_pull(from_posiiton : Vector2) -> Vector2:
	var offset_distance = global_position - from_posiiton
	var distance = offset_distance.length()
	
	if distance > pull_radius or distance < no_grav_radius:
		return Vector2.ZERO
	
	var strength = (mass * MASS_SCALE) / max(distance**2, MAX_GRAV_STRENGTH)
	
	return offset_distance.normalized() * strength
