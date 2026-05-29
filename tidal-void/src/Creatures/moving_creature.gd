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
		
	if(b_in_hibernation):
		hibernation_movement(altitude_sqr)
	else:
		orbital_movment(altitude_sqr)
	
		
func orbital_movment(altitude_sqr : float):
	# return from deep space
	if(altitude_sqr > dominant_body.pull_radius ** 2):
		var dir : Vector2 = (dominant_body.global_position - global_position).normalized();
		var min_compliance = 40;
		if(velocity.dot(dir) < min_compliance):
			set_thrust(dir)
		return
		
	var grav_dir = (dominant_body.global_position - global_position).normalized()
	
	# move dir is tangent to gravity
	var move_dir = Vector2(grav_dir.y,-grav_dir.x)
	
	#Align move_dir with target dir
	if(!target_dir):
		move_dir = -move_dir
		
	var target_speed = sqrt(dominant_body.mass / sqrt(target_altitude_sqr))
		
	var velocity_grounded_threshold_sqr :float = 400 
		
	if(b_is_grounded && velocity.length_squared() < velocity_grounded_threshold_sqr):
		velocity += move_dir * sqrt((dominant_body.mass / 
		sqrt(altitude_sqr))) * 1.2
		
	
	var velocity_length : float= velocity.length();
	
	var velocity_normalized : Vector2 = velocity/velocity_length
	
	var velocity_dot = velocity_normalized.dot(move_dir)
	
	#velocity deviation from the perfect circle
	var velocity_deviation = move_dir - velocity_normalized
		
	var acceptable_deviation = 0.2;
	
	if(velocity_deviation.length_squared() < acceptable_deviation):
		velocity_deviation =Vector2.ZERO
		
	var altitude_diff = altitude_sqr - target_altitude_sqr;
	
	var deadzone = 100
	
	if abs(altitude_diff) < deadzone:
		set_thrust(velocity_deviation)
	elif velocity_dot < -0.05:
		#if we are going against the move direction, fall to the planet to swap the direction
		set_thrust(-velocity_normalized);
	elif ((altitude_diff < 0 && velocity_length < 1.5*target_speed)):
		#burn prograde
		set_thrust(move_dir + velocity_deviation);
	elif(velocity.dot(move_dir) > 0.7*target_speed):
		#burn retrograde
		set_thrust(-move_dir+velocity_deviation);
	else:
		set_thrust(-move_dir+velocity_deviation,0.1)
		
		
func hibernation_movement(altitude_sqr : float):
	# return from deep space
	if(altitude_sqr > dominant_body.pull_radius ** 2):
		var dir : Vector2 = (dominant_body.global_position - global_position).normalized();
		var min_compliance = 45;
		if(velocity.dot(dir) < min_compliance):
			set_thrust(dir)
		return
	set_thrust(Vector2.ZERO)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
func on_collide_with_bubble(bubble : Bubble) -> void:
	super.on_collide_with_bubble(bubble)
	stun_time = 1
	b_in_hibernation = true
	set_thrust(Vector2.ZERO)
