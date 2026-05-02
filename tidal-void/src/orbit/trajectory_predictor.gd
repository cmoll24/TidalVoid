class_name TrajectoryPredictor
extends Node

##Reference to line used to draw a predicted trajectory, should have antialiasing on
@export var line : Line2D
##The number of simulated physics steps to use
@export var steps : int = 10_000
##the amount of fake steps to place in between real physics steps to make the line smooth
@export var fake_steps : float = 5;
## The amount of steps to traverse in each step, numbers over 1 skip steps to save on performance,may cause some stuttering in the trajectory, should be used was fake steps to avoid pointy lines
@export var step_dist : float = 20;
## Used to ensure accurate predications of when collision may occur, set to the radius of whatever is being predicted
@export var collision_radius : float = 15;
#@export var step_delta : float = 0.005
var game_manager : GameManager

@export var player : DriftBody

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")
	
	if player is Player:
		player.update_traj_color.connect(set_color)

func set_color(new_color : Color):
	line.modulate = new_color

func _physics_process(_delta: float) -> void:
	if(!player):
		line.points = []
		return
	draw_trajectory()

func draw_trajectory() -> void:
	var step = step_dist / ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	
	var sim_pos = player.global_position
	var sim_vel = player.prediction_velocity
	var points : PackedVector2Array = [sim_pos]
	
	for i in steps:
		#simulate gravity
		var grav = Vector2.ZERO
		for body in game_manager.gravity_sources:
			grav += body.get_gravity_pull(sim_pos)
		sim_vel += grav * step
		sim_vel = sim_vel.limit_length(player.max_velocity)
		sim_pos += sim_vel * step
		
		#we stop drwaing if we hit an orbital body
		var hit = false
		for body in game_manager.gravity_sources:
			var distance : float = sim_pos.distance_to(body.global_position)-collision_radius
			if  distance < body.collision_radius:
				hit = true
				var past_pos = points[points.size()-1]
				var delta : Vector2 = sim_pos - past_pos
				sim_pos = lerp(past_pos,sim_pos,(distance-body.collision_radius)
				/delta.length())
				break
		
		#first add steps interpolating to the current step to keep the curve smooth
		var count = points.size()
		if(count > 1):
			var past_pos : Vector2 = points[count-1]
			var past_pos_tan : Vector2 = (past_pos - points[count -2])
			for j in range(1,fake_steps):
				var progress = (float)(j)/fake_steps
				var lin_pos = lerp(past_pos,sim_pos,progress)
				var tan_pos = lerp(Vector2.ZERO,past_pos_tan,
				progress)
				var inter_pos = lerp(past_pos+tan_pos,lin_pos,progress)
				points.append(inter_pos)
		#Now append actual location of new physics step
		points.append(sim_pos)
		if hit:
			break
	
	line.points = points
