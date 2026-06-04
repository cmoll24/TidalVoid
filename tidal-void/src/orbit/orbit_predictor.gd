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
		print("no dom body")
		return
	
	var sim_pos = player.global_position
	var sim_vel = player.prediction_velocity
	
	#Our classic orbital variables of mu, radial_vector and velocity
	var mu : float = dominant.mass #mu = GM
	var r_vec : Vector2 = sim_pos - dominant.global_position
	var r : float = r_vec.length()
	var v_vec : Vector2 = sim_vel
	
	if r < 0.001:
		line.points = []
		return
	
	#specific orbital energy = kinetic energy - potential energy
	# KE = (1/2)mv^2
	var energy : float = v_vec.length_squared() / 2.0 - mu / r
	#specific angular momentum: h = L/m
	var h : float = r_vec.cross(v_vec)
	
	#if h = 0, it is flying at/away from the source
	if abs(h) < 0.001:
		# degenerate radial orbit which will give a line as it falls to surface
		line.points = []
		return
	
	#Vis-viva equation v^2 = mu * (2/r - 1/a)
	
	var h2 = h * h
	#eccentricity
	var ecc_sq = 1.0 + (2.0 * energy * h2) / (mu * mu)
	
	#test if it's a hyperolic or escape traj
	if ecc_sq < 0.0:
		line.points = []
		return
	
	var ecc = sqrt(ecc_sq)
	
	#semi-latus rectum
	var p = h2 / mu
	
	if ecc >= 1.0:
		# hyperbolic trajectory arc
		line.points = []
		return
	
	# semi-major and semi-minor axes
	var a = p / (1.0 - ecc ** 2)
	var b = a * sqrt(1.0 - ecc ** 2)
	
	# periapsis direction — the direction of the eccentricity vector
	# eccentricity vector points from focus toward periapsis
	var ecc_vec = get_eccentricity_vector(r_vec, v_vec, mu)
	var periapsis_angle = ecc_vec.angle()

	# draw the ellipse
	draw_ellipse(dominant.global_position, a, b, ecc, periapsis_angle, h)

func get_eccentricity_vector(r_vec: Vector2, v: Vector2, mu: float) -> Vector2:
	# e_vec = (v × h) / μ - r_hat
	# in 2D: v × h = v rotated 90° scaled by h magnitude
	var h_scalar = r_vec.cross(v)
	# (v × h) in 2D = Vector2(-v.y, v.x) * h_scalar / mu - r_hat
	var v_cross_h = Vector2(v.y, -v.x) * h_scalar / mu
	var e_vec = v_cross_h - r_vec.normalized()
	return -e_vec

func draw_circle(center : Vector2, radius : float):
	var points: PackedVector2Array = []
	
	var start_angle = (player.global_position - center).angle()

	for i in resolution + 1:
		var angle = start_angle + (float(i) / resolution) * TAU
		points.append(center + Vector2.from_angle(angle) * radius)

	line.points = points

func draw_ellipse(focus: Vector2, 
	a: float, b: float, ecc: float, 
	periapsis_angle: float, h : float
	) -> void:
		
	var points: PackedVector2Array = []

	var c = a * ecc
	var center = focus + Vector2.from_angle(periapsis_angle) * c

	# convert player position to local unrotated ellipse space
	var player_local = (player.global_position - center).rotated(-periapsis_angle)
	var start_angle = atan2(player_local.y / b, player_local.x / a)

	var direction = 1 if h > 0 else -1

	var collision_radius_sq = player.dominant_body.collision_radius ** 2

	for i in resolution + 1:
		var angle = start_angle + direction * (float(i) / resolution) * TAU
		var local_point = Vector2(a * cos(angle), b * sin(angle))
		
		# rotate the point to match orbit orientation before adding to world space
		var new_point = center + local_point.rotated(periapsis_angle)
		
		if focus.distance_squared_to(new_point) < collision_radius_sq:
			break
		
		points.append(new_point)

	line.points = points
