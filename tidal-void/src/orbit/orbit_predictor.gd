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
	
	#Our classic orbital variables of mu, radial_vector and velocity
	var mu : float = dominant.mass #mu = GM
	var r_vec : Vector2 = player.global_position - dominant.global_position
	var r : float = r_vec.length()
	var v_vec : Vector2 = player.velocity
	
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
	
	if ecc >= 1.0:
		# hyperbolic trajectory arc
		return
	
	#semi-latus rectum
	var p = h2 / mu
	
	# semi-major and semi-minor axes
	var a = p / (1.0 - ecc ** 2)
	var b = a * sqrt(1.0 - ecc ** 2)
	
	# periapsis direction — the direction of the eccentricity vector
	# eccentricity vector points from focus toward periapsis
	var ecc_vec = get_eccentricity_vector(r_vec, v_vec, mu)
	var periapsis_angle = ecc_vec.angle()

	# current true anomaly — angle of current position from periapsis
	var true_anomaly = get_true_anomaly(r_vec, ecc_vec, h)

	# draw the ellipse
	draw_ellipse(dominant.global_position, a, b)#, ecc, periapsis_angle, true_anomaly, h)

func get_eccentricity_vector(r_vec: Vector2, v: Vector2, mu: float) -> Vector2:
	# e_vec = (v × h) / μ - r_hat
	# in 2D: v × h = v rotated 90° scaled by h magnitude
	var h_scalar = r_vec.cross(v)
	# (v × h) in 2D = Vector2(-v.y, v.x) * h_scalar / mu - r_hat
	var e_vec = Vector2(-v.y, v.x) * h_scalar / mu - r_vec.normalized()
	return e_vec

func get_true_anomaly(r_vec: Vector2, ecc_vec: Vector2, h: float) -> float:
	# true anomaly is angle between eccentricity vector and position vector
	var ecc_mag = ecc_vec.length()
	if ecc_mag < 0.0001:
		# circular orbit — use angle from reference direction
		return r_vec.angle()

	var cos_nu = ecc_vec.dot(r_vec.normalized()) / ecc_mag
	cos_nu = clamp(cos_nu, -1.0, 1.0)
	var nu = acos(cos_nu)

	# sign from angular momentum — if h < 0 orbit is clockwise
	if h < 0:
		nu = -nu
	# if moving away from periapsis (radial velocity positive), nu is positive
	# already handled by eccentricity vector construction
	return nu

func _true_to_eccentric_anomaly(nu: float, ecc: float) -> float:
	# converts true anomaly to eccentric anomaly for ellipse parameter
	var cos_e = (ecc + cos(nu)) / (1.0 + ecc * cos(nu))
	var sin_e = sqrt(1.0 - ecc * ecc) * sin(nu) / (1.0 + ecc * cos(nu))
	return atan2(sin_e, cos_e)

func draw_circle(center : Vector2, radius : float):
	var points: PackedVector2Array = []
	
	var start_angle = (player.global_position - center).angle()

	for i in resolution + 1:
		var angle = start_angle + (float(i) / resolution) * TAU
		points.append(center + Vector2.from_angle(angle) * radius)

	line.points = points

func draw_ellipse(focus : Vector2, a : float, b : float):
	var points: PackedVector2Array = []
	
	var c = sqrt(a ** 2 - b ** 2)  # distance from center to focus
	var center = focus + Vector2.from_angle(0) * c
	
	var start_angle = (player.global_position - center).angle()
	
	# Calculate points along the ellipse
	for i in resolution + 1:
		var angle = start_angle + (float(i) / resolution) * TAU
		var x := a * cos(angle)
		var y := b * sin(angle)
		points.append(center + Vector2(x, y))
	
	line.points = points
