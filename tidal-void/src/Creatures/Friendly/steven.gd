extends MovingCreature
class_name Steven


############################################

### the max distance at which things can be seen by vision
@export var v_distance : float = 1200

### types of things it cares about in vision (bitmask), see VisionSource.gd
var v_types : int

### all visible vision sources
var v_sources : Array[VisionSource]

### the primary visible vision source(the target)
var primary_v_source : VisionSource

### the amount of time steven will continue to follow the
### same target even after it has gone out of sight
@export var v_source_loyalty_time : float = 3

### continue to follow the same source until one is closer by this factor
### e.g. follow unless something twice as close appears
@export var v_source_loyalty_dist : float = 2;

var primary_v_source_time : float = 0

##squared
var last_primary_source_dist : float = 0;

var time_since_last_vision : float = 0;

var time_before_hibernate : float = 12;

################################################




func _ready() -> void:
	super._ready()
	#set the vision bitmask( use the | operator to add more)
	v_types = 1 << VisionSource.v_source_type.sFood
	
func post_ready() -> void:
	##Hook up to the vision timer
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)
	
func creature_movement(_delta):
	super.creature_movement(_delta)
	
func update_vision():
	#update array of all visible v_sources
	v_sources = game_manager.sense_manager.check_vision(self,v_distance,v_types)
	
	var lowest_dist : float = 99999999999
	
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
			v_move_dir = Vector2(v_move_dir.y,-v_move_dir.x).normalized()
			#move the opposite directiton to maximize chances of catching up
			target_dir = (v_move_dir.dot(primary_v_source.parent.get_velocity()) < 0)
	else:
		##keep roughly in our orbit unless hibernating
		if(!b_in_hibernation):
			target_altitude_sqr = min(
				(dominant_body.pull_radius-30)**2,
				get_square_altitude(dominant_body))
			
		
