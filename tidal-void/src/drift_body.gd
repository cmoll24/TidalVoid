class_name DriftBody
extends RigidBody2D

@export var gravity_bodies : Array[GravitySource] = []

func _ready() -> void:
	gravity_scale = 0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

func apply_gravity(delta : float) -> void:
	var total_gravity = Vector2.ZERO
	
	for body in gravity_bodies:
		total_gravity += body.get_gravity_pull(global_position)
	apply_central_force(total_gravity)
