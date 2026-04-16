extends MovingCreature
class_name Steven


############################################

### the max distance at which things can be seen by vision
@export var v_distance : float = 1200

### types of things it cares about in vision (bitmask), see vision_source.gd
var v_types : int

### all visible vision sources
var v_sources : Array[vision_source]

### the primary visible vision source(the target)
var primary_v_source : vision_source

### the amount of time steven will continue to follow the
### same target even after it has gone out of sight
@export var v_source_loyalty_time : float = 3

### continue to follow the same source until one is closer by this factor
### e.g. follow until the distance is twice as far
@export var v_source_loyalty_dist : float = 2;

var primary_v_source_time : float = 0

##squared
var last_primary_source_dist : float = 0;

################################################

###The altitude to go to when not actively chasing a target
@export var default_altitude : float = 50;

func _ready() -> void:
	super._ready()
	#set the vision bitmask( use the | operator to add more)
	v_types = vision_source.v_source_type.sFood
	call_deferred("post_ready")
	
func post_ready() -> void:
	##Hook up to the vision timer
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)
	
func creature_movement(_delta):
	#set the target altitude to match the primary v source
	if(dominant_body && primary_v_source):
		var v_alt : float = dominant_body.global_position.distance_to(primary_v_source.parent.global_position)
		if(v_alt > dominant_body.pull_radius):
			#don't chase things out of orbit
			primary_v_source = null
		else:
			target_altitude = v_alt
	else:
		target_altitude = default_altitude;
	super.creature_movement(_delta)
	
func update_vision():
	#update array of all visible v_sources
	v_sources = game_manager.sense_manager.check_vision(self,v_distance,v_types)
	
	var highest_dist : float = 0
	
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
			highest_dist = last_primary_source_dist * v_source_loyalty_dist
	
	#set the primary source to the closest one
	
	for v in v_sources:
		var dist : float =(global_position - v.parent.global_position).length_squared()
		if(dist > highest_dist):
			primary_v_source = v;
			highest_dist = dist	
			last_primary_source_dist = dist	

	
	
			
		
