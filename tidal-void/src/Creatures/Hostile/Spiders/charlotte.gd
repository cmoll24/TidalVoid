extends Steven
class_name Charlotte

var home_planet : InfestedPlanet = null

@export var walk_speed : float = 750

#cooldown on using the web attack
@export var web_cldwn_time : float = 5

var web_cldwn : float = 0

@export var bite_damage : float = 45
@export var bite_knockback : float = 10

#the square distance away from a spider hole at which a charlotte can burrow back in
var burrow_distance_sqr : float = 400

#used to drive grounded animation
var ground_move_direction : int = -1

#checks to see if orbit was left
var b_on_home_planet : bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#get the home planet
	var shortest_dist : float = INF
	for source in game_manager.gravity_sources:
		if(source is InfestedPlanet):
			var dist_sqr = global_position.distance_squared_to(source.global_position);
			if(dist_sqr < shortest_dist):
				home_planet = source
				shortest_dist = dist_sqr
	#set the v types
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#decrement web cooldown
	web_cldwn -= delta
	#see if we left home
	check_on_home_planet()
	
func check_on_home_planet():
	if(!home_planet):
		return
	if(dominant_body != home_planet):
		if(b_on_home_planet):
			#tell home planet we left
			home_planet.spiders_outside -= 1
		b_on_home_planet = false
	else:
		if(!b_on_home_planet):
			#tell home planet we returned
			home_planet.spiders_outside += 1
		b_on_home_planet = true
	
func creature_movement(_delta):
	if stun_time > 0:
		return
	
	if !dominant_body || !home_planet:
		return
		
		
	#correct altitude
	if(time_since_last_vision > 2 || target_altitude_sqr < home_planet.stay_grounded_altitude_sqr):
		target_altitude_sqr = 5
		
	#conditions for grounded movement
	if(b_is_grounded && grounded_body && (target_altitude_sqr == 5 || !primary_v_source)):
		ignore_layer = 1
		grounded_movement()
	else:
		ignore_layer = 0
		#do default movement
		super.creature_movement(_delta)
		#check if we should shoot a web
		var WEB_SHOOT_DIST_SQR : float = 1600
		if(web_cldwn <= 0 and abs(target_altitude_sqr-get_square_altitude(dominant_body)) < WEB_SHOOT_DIST_SQR):
			shoot_web()

	
				
func grounded_movement():
	#Exit Condition
	if(velocity.dot(grounded_normal) < -1):
		grounded_buffer = 0
	else:
		#remove velocity
		velocity = Vector2.ZERO
		
	#turn off thrust
	thrust_direction = Vector2.ZERO
	thrust_particles.emitting = false
	
	var radial_loc : Vector2 = global_position - grounded_body.global_position
	var radial_loc_len : float = collision_shape.shape.radius
	if(grounded_shape is CircleShape2D):
		radial_loc_len += grounded_body.collision_radius- 1
	else:
		radial_loc_len += grounded_body.global_position.distance_to(grounded_point) - 1
	var radial_angle : float = radial_loc.angle()
	var new_pos : Vector2
	var horizontal_mov = Input.get_axis("thrust_left", "thrust_right")
	var final_angle : float
	var rot_speed = (walk_speed/(2*PI*radial_loc_len)) * get_physics_process_delta_time()
	if primary_v_source:
		#if we see something, move towards it
		var v_loc : Vector2 = get_global_mouse_position() - grounded_body.global_position
		var v_angle : float = v_loc.angle()
		#save the move direction
		ground_move_direction = 1 if v_angle -  radial_angle > 0 else -1;
		final_angle = rotate_toward(radial_angle,v_angle,rot_speed);
	else:
		# if we see nothing, wrap around clockwise
		final_angle = radial_angle+(rot_speed*ground_move_direction);
	new_pos = (Vector2.from_angle(final_angle)*
	radial_loc_len)+ grounded_body.global_position
	global_position = new_pos
	
	
	#check to see if burrowing is a good idea
	if(b_in_hibernation):
		for hole in home_planet.spider_holes:
			if(global_position.distance_squared_to(hole) < burrow_distance_sqr):
				burrow();
				break;
				
func shoot_web():
	var web  : WebProjectile= preload("res://src/Creatures/Hostile/Spiders/web_projectile.tscn").instantiate()
	web.global_position = global_position
	#make sure it follows the right orbit
	web.b_start_in_orbit_dir = target_dir
	#complete spawning
	get_tree().root.add_child(web)
	#set cooldown
	web_cldwn = web_cldwn_time


func hibernation_movement(altitude_sqr : float):
	orbital_movment(altitude_sqr)

func burrow():
	home_planet.spiders_inside += 1
	home_planet.spiders_outside -= 1
	queue_free()

func die():
	if(!b_dead):
		super.die()
		if(home_planet):
			home_planet.spiders_outside -= 1
			
func on_collide_with_other_drift_body(other : DriftBody) -> void:
	super.on_collide_with_other_drift_body(other);
	
	#check if it is another spider, if so let them share vision
	if(other is Charlotte):
		if(!primary_v_source and other.primary_v_source):
			primary_v_source = other.primary_v_source
			time_since_last_vision = 0	
			ground_move_direction = other.ground_move_direction
	
	#damage the drift body if vision confirms it to be prey
	var vs : VisionSource = other.get_node_or_null("VisionSource")
	if(vs && (1 << vs.v_type) & v_types):
		if(vs == primary_v_source):
			primary_v_source = null;
		if(other):
			#deal knockback and physical damage if a health component exists
			var hc : HealthComponent = other.get_node_or_null('HealthComponent')
			if(hc):
				#physical damage
				hc.take_damage(bite_damage,HealthComponent.e_dmg_types.physical,self,self)
				#knockback damage
				hc.take_damage(bite_knockback,HealthComponent.e_dmg_types.knockback,self,self)
				
				
func save() -> Dictionary:
	var node_data : Dictionary = {
		home = b_on_home_planet
	}
	node_data.merge(super.save())
	return node_data
	
func load_state(node_data : Dictionary):
	super.load_state(node_data)
	b_on_home_planet = node_data['home']
	
