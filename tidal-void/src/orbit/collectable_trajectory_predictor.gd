class_name CollecTrajectoryPredictor
extends Node

@export var line : Line2D
@export var steps : int = 2000
@export var gravity_sources : Array[GravitySource]

@export var collectable : Collectable

func _process(_delta: float) -> void:
	if not collectable:
		line.queue_free()
		queue_free()
	else:
		draw_trajectory()

func draw_trajectory() -> void:
	var step = 1.0 / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	
	var sim_pos = collectable.global_position
	var sim_vel = collectable.velocity
	var points : PackedVector2Array = [sim_pos]
	
	for i in steps:
		#simulate gravity
		var grav = Vector2.ZERO
		for body in gravity_sources:
			grav += body.get_gravity_pull(sim_pos)
		sim_vel += grav * step
		sim_pos += sim_vel * step
		
		#we stop drwaing if we hit an orbital body
		var hit = false
		for body in gravity_sources:
			if sim_pos.distance_to(body.global_position) < body.collision_radius:
				hit = true
				break
		if hit:
			break
		else:
			points.append(sim_pos)
	
	line.points = points
