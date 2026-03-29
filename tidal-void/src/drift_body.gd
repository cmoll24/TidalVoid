class_name DriftBody
extends RigidBody2D

@onready var gravity_label = $GravityLabel

@export var thrust_power : float = 90.0
@export var max_velocity : float = 400.0

@export var gravity_bodies : Array[GravitySource] = []

var thrust_direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	apply_thrust(delta)

func apply_gravity(delta : float) -> void:
	var total_gravity = Vector2.ZERO
	
	for body in gravity_bodies:
		total_gravity += body.get_gravity_pull(global_position)
		
	gravity_label.text = str(round(total_gravity.length())) + " N"
	apply_central_force(total_gravity)

func apply_thrust(delta : float) -> void:
	if thrust_direction == Vector2.ZERO:
		return
	apply_central_force(thrust_direction * thrust_power)

func set_thurst(direction : Vector2) -> void:
	if direction.length() > 0.1:
		thrust_direction = direction.normalized()
	else:
		thrust_direction = Vector2.ZERO
