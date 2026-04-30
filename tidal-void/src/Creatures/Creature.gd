class_name Creature
extends DriftBody

### if greater than 0, behavior is disabled and time will be brought down
@export var stun_time : float = 0

func _ready() -> void:
	super._ready()
	start_in_orbit = true
	

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#decrement stun time
	stun_time -= delta
	# run creature movement
	creature_movement(delta)

func creature_movement(delta):
	pass
	
func get_square_altitude(body : GravitySource):
	return global_position.distance_squared_to(body.global_position)
	

func get_opposite_altitude(body : GravitySource,pos : Vector2) -> float:
	var mu = body.mass #mu = GM
	var r_vec = pos - body.global_position
	var r = r_vec.length()
	var v = velocity.length()
	
	#specific orbital energy = kinetic energy - potential energy
	var energy = (v * v) / 2.0 - mu / r
	#specific angular momentum: h = L/m
	var h = r_vec.cross(velocity)
	
	#if h = 0, it is flying at/away from the source
	if abs(h) < 0.001:
		return -1.0
	
	#Vis-viva equation v^2 = mu * (2/r - 1/a)
	
	var h2 = h * h
	#eccentricity
	var ecc_sq = 1.0 + (2.0 * energy * h2) / (mu * mu)
	
	#test if it's a hyperolic or escape traj
	if ecc_sq < 0.0:
		return INF
	
	var ecc = sqrt(ecc_sq)
	
	#semi-latus rectum
	var p = h2 / mu
	
	# periapsis and apoapsis distances from body center
	var r_peri = p / (1.0 + ecc)
	var r_apo  = p / (1.0 - ecc) if ecc < 1.0 else INF
	
	#find the opposite
	var r_opposite = r_apo if r < (r_peri + r_apo) / 2.0 else r_peri
	return r_opposite - body.collision_radius
