class_name OrbitPredictor
extends Node

## A second approach to predicting orbital trajectories is to use orbital mechanics
## The idea of this node is to test if this second approach runs more efficiently then TrajectoryPredictor
## The only downside of this approach is we will assume a single dominant gravity source

##Reference to line used to draw a predicted trajectory, should have antialiasing on
@export var line : Line2D

#@export var draw_full_orbit: bool = true
#@export var arc_ahead: float = PI * 1.5
@export var resolution: int = 128

var game_manager : GameManager

@export var player : DriftBody

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")
	
	if(player is PlayerPawn):
		update_player(player)

func remove_target():
	player = null

func set_target(drift_body : DriftBody):
	player = drift_body

func update_player(pawn : PlayerPawn):
	set_target(pawn)
	player.update_traj_color.connect(set_color)

func set_color(new_color : Color):
	line.modulate = new_color

func _process(_delta: float) -> void:
	if(!player):
		line.points = []
		return
	draw_orbit()

func draw_orbit() -> void:
	var dominant = player.dominant_body
	if not dominant:
		line.points = []
		return
	
	var center = dominant.global_position
	var radius = player.global_position.distance_to(dominant.global_position)
	draw_circle(center, radius)

func draw_circle(center : Vector2, radius : float):
	var points: PackedVector2Array = []
	
	var start_angle = (player.global_position - center).angle()

	for i in resolution + 1:
		var angle = start_angle + (float(i) / resolution) * TAU
		points.append(center + Vector2.from_angle(angle) * radius)

	line.points = points
