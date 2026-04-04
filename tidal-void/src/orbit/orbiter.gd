class_name Orbiter
extends Area2D

var game_manager : GameManager
var velocity : Vector2 = Vector2.ZERO

@onready var on_screen_notifier : VisibleOnScreenNotifier2D  = $VisibleOnScreenNotifier2D



func _ready() -> void:
	
	game_manager = get_tree().get_first_node_in_group("game_managers")
	call_deferred("after_ready");

func after_ready() -> void:
	velocity = orbital_velocity(get_dominant_body(), global_position)
	
	
	var line : Line2D = Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.7, 0.3, 0.3, 0.5)
	var gradient_data := { 0.0: Color.from_rgba8(200, 12, 0, 131), 
	1.0: Color.from_rgba8(241, 67, 104, 0), }
	var gradient := Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()
	line.gradient = gradient
	get_parent().add_child.call_deferred(line)
	
	var collectable_traj_predict : CollecTrajectoryPredictor = CollecTrajectoryPredictor.new()
	collectable_traj_predict.line = line
	collectable_traj_predict.collectable = self
	collectable_traj_predict.steps = 20
	collectable_traj_predict.step_dist = 25;
	collectable_traj_predict.fake_steps = 5;
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
	for body in game_manager.gravity_sources:
		var pull = body.get_gravity_pull(global_position).length_squared()
		if pull > strongest_pull:
			strongest_pull = pull
			dominant_body = body
	return dominant_body

func _physics_process(delta: float) -> void:
	var total_gravity = Vector2.ZERO
	
	for body in game_manager.gravity_sources:
		total_gravity += body.get_gravity_pull(global_position)
	
	velocity += total_gravity * delta
	global_position += velocity * delta
