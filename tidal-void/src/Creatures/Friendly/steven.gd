extends MovingCreature
class_name Steven


############################################

### the max distance at which things can be seen by vision
@export var v_distance : float = 1200

### types of things it cares about in vision (bitmask), see VisionSource.gd
var v_types : int

### all visible vision sources
var v_sources : Array[VisionSource] = []

### the primary visible vision source(the target)
var primary_v_source : VisionSource 

var v_exceptions : Array[RID] = []

### the amount of time steven will continue to follow the
### same target even after it has gone out of sight
@export var v_source_loyalty_time : float = 3.0

### continue to follow the same source until one is closer by this factor
### e.g. follow unless something twice as close appears
@export var v_source_loyalty_dist : float = 2.0;

var primary_v_source_time : float = 0

##squared
var last_primary_source_dist : float = 0;

var time_since_last_vision : float = 0;

@export var time_before_hibernate : float = 12;

################################################

@export var b_can_lunge = true
@export var min_lunge_dist_sqr = 3600
@export var lunge_power = 100
@export var lunge_cldwn_time = 6
var lunge_cldwn : float

func _ready() -> void:
	super._ready()
	#set the vision bitmask( use the | operator to add more)
	v_types = 1 << VisionSource.v_source_type.sFood
	call_deferred("post_ready")
	
func post_ready() -> void:
	##Hook up to the vision timer
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)
	
func creature_movement(delta):
	super.creature_movement(delta)
	#lunge if we are close, have a target and are not on cooldown
	if(b_can_lunge):
		lunge_cldwn -= delta
		if(primary_v_source && lunge_cldwn <= 0):
			var dist_sqr : float = global_position.distance_squared_to(primary_v_source.parent.global_position)
			if(dist_sqr < min_lunge_dist_sqr):
				lunge(sqrt(dist_sqr))
	
func update_vision():
	#do nothing if stunned
	if stun_time > 0:
		return
	#update array of all visible v_sources
	v_sources = game_manager.sense_manager.check_vision(self,v_distance,v_types,v_exceptions)
	
	var lowest_dist : float = INF
	
	#Check loyalty to the primary source(prevent the creature from switching too often)
	if(primary_v_source):
		if(v_sources.has(primary_v_source)):
			primary_v_source_time = v_source_loyalty_time
			last_primary_source_dist = (global_position - primary_v_source.parent.global_position).length_squared()
		else:
			primary_v_source_time -= game_manager.sense_manager.vision_timer.wait_time
			
		if(primary_v_source_time <= 0):
			primary_v_source = null
			last_primary_source_dist = 0;
		else:
			#enforce loyalty distance
			lowest_dist = last_primary_source_dist / v_source_loyalty_dist
		time_since_last_vision = 0;
	else:
		time_since_last_vision += game_manager.sense_manager.vision_timer.wait_time
	
	
	#set the primary source to the closest one
	
	for v in v_sources:
		var dist : float =(global_position - v.parent.global_position).length_squared()
		if(dist < lowest_dist):
			if(dominant_body):
				var v_alt : float = dominant_body.global_position.distance_squared_to(v.parent.global_position)
				if(v_alt > dominant_body.pull_radius*dominant_body.pull_radius):
					#don't chase things out of orbit
					continue
			primary_v_source_time = v_source_loyalty_time
			primary_v_source = v;
			lowest_dist = dist	
			last_primary_source_dist = dist
			
	# with vision complete, update the behavior
	update_behavior()

	
func update_behavior() -> void:
	#check for hibernation
	b_in_hibernation = time_since_last_vision > time_before_hibernate
		
	#set the target altitude to match the primary v source
	if(dominant_body && primary_v_source):
		var v_alt : float = dominant_body.global_position.distance_squared_to(primary_v_source.parent.global_position)
		target_altitude_sqr = v_alt
		# get the dir
		if(primary_v_source && primary_v_source.parent.has_method("get_velocity")):
			var v_move_dir = (dominant_body.global_position - primary_v_source.parent.global_position)
			# move dir is tangent to gravity
			v_move_dir = Vector2(v_move_dir.y,-v_move_dir.x)
			#move the opposite directiton to maximize chances of catching up
			target_dir = (v_move_dir.dot(primary_v_source.parent.get_velocity()) < 0)
	else:
		##keep roughly in our orbit unless hibernating
		if(!b_in_hibernation):
			if(dominant_body):
				target_altitude_sqr = min(
					(dominant_body.pull_radius-30)**2,
					get_square_altitude(dominant_body))
					
					
func lunge(dist : float):
	if !primary_v_source:
		return # only procede if primary_v_source is valid
	#calculate a lead of the target
	var target_point : Vector2 = primary_v_source.parent.global_position
	
	### I REMOVED THE IMPACT TIME LOOK AHEAD AS IT WAS LOOKING TOO FAR AHEAD
	#var impact_time : float = (dist - collision_shape.shape.get_rect().size.x/2) / thrust_power
	
	if(primary_v_source.parent.has_method("get_velocity")):
		target_point += 0.5 * (primary_v_source.parent.get_velocity())
	else:
		return
	#lunge at the target point
	var lunge_dir : Vector2  = (target_point - global_position).normalized()
	
	velocity = lunge_dir *lunge_power
	
	#counteract gravity if needed
	#if(lunge_dir.dot(gravity_force) < -0.1):
		#velocity -= (gravity_force*impact_time*0.5)
	
	#reset the cooldown
	lunge_cldwn = lunge_cldwn_time

# +++++++++++++++ DRAW DEBUG ++++++++++++++++++++++
#var draw_debug : bool = true
#
#func _process(_delta: float) -> void:
	#queue_redraw()
#
#func _draw() -> void:
	#if not draw_debug:
		#return
	#if !primary_v_source:
		#return # only procede if primary_v_source is valid
#
	#
	#var lunge_radius: float = sqrt(min_lunge_dist_sqr)
	#
	#var radius_color: Color = Color(1.0, 0.3, 0.3, 0.4) if lunge_cldwn > 0 else Color(0.3, 1.0, 0.3, 0.4)
	#draw_arc(Vector2.ZERO, lunge_radius, 0.0, TAU, 64, radius_color, 1.5, true)
	#
	#if primary_v_source.parent:
		#var local_target: Vector2 = to_local(primary_v_source.parent.global_position)
		#
		#draw_line(Vector2.ZERO, local_target, Color.CHARTREUSE, 2.0)
