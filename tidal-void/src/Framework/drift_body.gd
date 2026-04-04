class_name DriftBody
extends RigidBody2D

@onready var gravity_label = $GravityLabel

@export var thrust_power : float = 50.0
@export var max_velocity : float = 400.0

var game_manager : GameManager
var dominant_body : GravitySource = null

var thrust_direction : Vector2 = Vector2.ZERO

func _ready() -> void:
	gravity_scale = 0
	game_manager = get_tree().get_first_node_in_group("game_managers")

func _physics_process(_delta: float) -> void:
	update_dominant_body()

func set_thurst(direction : Vector2) -> void:
	if direction.length() > 0.1:
		thrust_direction = direction.normalized()
	else:
		thrust_direction = Vector2.ZERO

func update_dominant_body() -> void:
	#the domiannt body is the grav source with the strongest pull
	var strongest_pull = 0.0
	dominant_body = null
	for body in game_manager.gravity_sources:
		var pull = body.get_gravity_pull(global_position).length()
		if pull > strongest_pull:
			strongest_pull = pull
			dominant_body = body

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# NOTE: requires "Custom Integrator" = true on the RigidBody2D
	
	var total_gravity = Vector2.ZERO
	
	for body in game_manager.gravity_sources:
		total_gravity += body.get_gravity_pull(global_position)
	
	var new_vel  = state.linear_velocity + total_gravity * state.step
	
	if thrust_direction != Vector2.ZERO:
		new_vel += thrust_direction * thrust_power * state.step
	
	state.linear_velocity = new_vel.limit_length(max_velocity)
	
	
	
	
