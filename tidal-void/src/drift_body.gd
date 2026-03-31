class_name DriftBody
extends RigidBody2D

@onready var gravity_label = $GravityLabel

@export var thrust_power : float = 50.0
@export var max_velocity : float = 400.0

@export var gravity_sources : Array[GravitySource] = []
var dominant_body : GravitySource = null

var thrust_direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0

func _physics_process(delta: float) -> void:
	apply_gravity()
	apply_thrust()
	update_dominant_body()

func apply_gravity() -> void:
	var total_gravity = Vector2.ZERO
	
	for body in gravity_sources:
		total_gravity += body.get_gravity_pull(global_position)
		
	gravity_label.text = str(round(total_gravity.length())) + " N"
	apply_central_force(total_gravity)

func apply_thrust() -> void:
	if thrust_direction == Vector2.ZERO:
		return
	apply_central_force(thrust_direction * thrust_power)

func set_thurst(direction : Vector2) -> void:
	if direction.length() > 0.1:
		thrust_direction = direction.normalized()
	else:
		thrust_direction = Vector2.ZERO

func update_dominant_body() -> void:
	#the domiannt body is the grav source with the strongest pull
	var strongest_pull = 0.0
	dominant_body = null
	for body in gravity_sources:
		var pull = body.get_gravity_pull(global_position).length()
		if pull > strongest_pull:
			strongest_pull = pull
			dominant_body = body
