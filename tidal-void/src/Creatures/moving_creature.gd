extends Creature
class_name MovingCreature


@onready var thrust_particles = $ThrustParticles

@export var target_altitude_sqr : float = 3600

###true for ccw, false for cc, orbital direction
@export var target_dir : bool = true

###when hibernating, movement will not be made except to escape deep space
@export var b_in_hibernation : bool = false

func _ready() -> void:
		super._ready()
		target_dir = start_orbit_dir
	

func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thrust(direction, multiplier)
	if direction != Vector2.ZERO:
		thrust_particles.start_thrust(direction, velocity, thrust_power)
	else:
		thrust_particles.stop_thrust()

func creature_movement(_delta):
	if stun_time > 0:
		return
	
	if not dominant_body:
		return
	
	var altitude_sqr = get_square_altitude(dominant_body)
	
	# return from deep space
	if(get_square_altitude(dominant_body) > dominant_body.pull_radius ** 2):
		var dir : Vector2 = (dominant_body.global_position - global_position).normalized();
		var min_compliance = 40;
		if(velocity.dot(dir) < min_compliance):
			set_thrust(dir)
		return
		
	if(b_in_hibernation):
		set_thrust(Vector2.ZERO)
		return
	
	var grav_dir = (dominant_body.global_position - global_position).normalized()
	
	# move dir is tangent to gravity
	var move_dir = Vector2(grav_dir.y,-grav_dir.x)
	
	#Align move_dir with target dir
	if(!target_dir):
		move_dir = - move_dir
		
	var velocity_grounded_threshold_sqr :float = 400 
		
	if(b_is_grounded && velocity.length_squared() < velocity_grounded_threshold_sqr):
		velocity += move_dir * sqrt((dominant_body.mass / 
		dominant_body.global_position.distance_to(global_position))) * 1.2
	
	var velocity_deviation = (
		move_dir - velocity.normalized())
		
	var acceptable_deviation = 0.1;
	
	if(velocity_deviation.length_squared() < acceptable_deviation):
		velocity_deviation =Vector2.ZERO
	var altitude_diff = altitude_sqr - target_altitude_sqr
	var deadzone = 36
	
	if abs(altitude_diff) < deadzone:
		set_thrust(velocity_deviation)
	elif altitude_diff < 0:
		set_thrust(move_dir + velocity_deviation)
	else:
		move_dir = -move_dir
		set_thrust(move_dir + velocity_deviation)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
		
@warning_ignore("unused_parameter")
func on_collide_with_bubble(bubble : Bubble) -> void:
	stun_time = 1
	b_in_hibernation = true
	set_thrust(Vector2.ZERO)
