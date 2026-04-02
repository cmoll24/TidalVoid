class_name Collectable
extends Area2D

@export var gravity_sources : Array[GravitySource] = []
var velocity : Vector2 = Vector2.ZERO

var debug = false

func _ready() -> void:
	gravity_sources.assign(get_tree().get_nodes_in_group("gravity_sources"))
	velocity = orbital_velocity(get_dominant_body(), global_position)
	
	if not debug:
		return
	
	var line : Line2D = Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.7, 0.3, 0.3, 0.5)
	get_parent().add_child.call_deferred(line)
	
	var collectable_traj_predict : CollecTrajectoryPredictor = CollecTrajectoryPredictor.new()
	collectable_traj_predict.line = line
	collectable_traj_predict.gravity_sources = gravity_sources
	collectable_traj_predict.collectable = self
	collectable_traj_predict.steps = 600
	get_parent().add_child.call_deferred(collectable_traj_predict)
	
	
func orbital_velocity(source : GravitySource, pos : Vector2) -> Vector2:
	if not source:
		return Vector2.ZERO
	
	var to_source = source.global_position - pos
	var distance = to_source.length()
	var speed = sqrt((source.mass * source.MASS_SCALE) / distance)
	return to_source.normalized().rotated(PI / 2.0) * speed

func get_dominant_body() -> GravitySource:
	var strongest_pull = 0.0
	var dominant_body : GravitySource = null
	for body in gravity_sources:
		var pull = body.get_gravity_pull(global_position).length()
		if pull > strongest_pull:
			strongest_pull = pull
			dominant_body = body
	return dominant_body

func _physics_process(delta: float) -> void:
	var total_gravity = Vector2.ZERO
	
	for body in gravity_sources:
		total_gravity += body.get_gravity_pull(global_position)
	
	velocity += total_gravity * delta
	global_position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body is DriftBody:
		queue_free()
