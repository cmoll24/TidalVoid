extends Area2D
class_name Orbiter


var game_manager : GameManager
var velocity : Vector2 = Vector2.ZERO
@export var b_start_in_orbit : bool = true
@export var b_start_in_orbit_dir : bool = true
@export var b_has_trajectory_predictor : bool = true
@export var b_simulate_gravity : bool = true
#the amount to sink into a gravity source before stopping, must be less than the collision radius
@export var f_grounded_sink_amount : float = 1
var grounded_radius : float

@onready var on_screen_notifier : VisibleOnScreenNotifier2D  = $VisibleOnScreenNotifier2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

func _enter_tree():
	#ensure orbiters are in the dynamic save group
	add_to_group('dynamic_save',true)

func _ready() -> void:
	#set the game manager and call after_ready
	game_manager = get_tree().get_first_node_in_group("game_managers")
	call_deferred("after_ready");
	#initialize values
	grounded_radius = ((collision_shape.shape.get_rect().size.x/2)-f_grounded_sink_amount)
func after_ready() -> void:
	if(b_start_in_orbit):
		velocity = GameManager.orbital_velocity(get_dominant_body(), global_position)
		if(b_start_in_orbit_dir):
			velocity = -velocity
	
	if(b_has_trajectory_predictor):
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
	#mitigate static bodies by fake rotation
	rotate(0)
	#only go forward is we are simulating gravity right now
	if(!b_simulate_gravity):
		return
	#enumerate gravity and get dominant body
	var total_gravity = Vector2.ZERO
	
	for body in game_manager.gravity_sources:
		#get the gravity
		var gravity_pull = body.get_gravity_pull(global_position);
		if(gravity_pull != Vector2.ZERO):
			total_gravity += gravity_pull
			#check for grounding
			var dist_sqr : float = global_position.distance_squared_to(body.global_position)
			if(dist_sqr <= (body.collision_radius + grounded_radius)**2 ):
				#stop physics so the orbiter can be fully grounded on the planet
				b_simulate_gravity = false
				#add as child to ensure that the orbiter will follow a moving gravity source
				reparent(body)
				return
					
			
	#set and apply velocity
	velocity += total_gravity * delta
	global_position += velocity * delta
	
func get_velocity() -> Vector2:
	return velocity
	
#save the velocity	
func save():
	var node_data : Dictionary = {
		"velo_x" : velocity.x,
		"velo_y" : velocity.y}
	return node_data
	
#load the velocity
func load_state(node_data : Dictionary):
	velocity.x = node_data["velo_x"]
	velocity.y = node_data["velo_y"]
