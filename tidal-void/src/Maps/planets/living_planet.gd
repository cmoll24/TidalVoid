extends Planet
class_name LivingPlanet

#speed at which the planet rotates to face prey
@export var rot_speed :float = 0.6

##########################################

### the max distance at which things can be seen by vision
@export var v_distance : float = 1200

### types of things it cares about in vision (bitmask), see VisionSource.gd
var v_types : int

### all visible vision sources
var v_sources : Array[VisionSource]

### the primary visible vision source(the target)
var primary_v_source : VisionSource

var v_exceptions : Array[RID] = []

### the amount of time to follow the
### same target even after it has gone out of sight
@export var v_source_loyalty_time : float = 3

### continue to follow the same source until one is closer by this factor
### e.g. follow unless something twice as close appears
@export var v_source_loyalty_dist : float = 2;

var primary_v_source_time : float = 0

##squared
var last_primary_source_dist : float = 0;

var time_since_last_vision : float = 0;

###########################################

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	game_manager = get_tree().get_first_node_in_group("game_managers")
	#set the vision bitmask( use the | operator to add more)
	v_types = 1 << VisionSource.v_source_type.mPrey
	call_deferred("post_ready")
	
func post_ready() -> void:
	##Hook up to the vision timer
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)
	
func _physics_process(delta: float) -> void:
	super.set_physics_process(delta)
	if(primary_v_source):
		var new_dir : float = (primary_v_source.parent.global_position - global_position).angle()+PI/2
		global_rotation = rotate_toward(global_rotation,new_dir,rot_speed*delta);
	
func update_vision():
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
			primary_v_source_time = v_source_loyalty_time
			primary_v_source = v;
			lowest_dist = dist	
			last_primary_source_dist = dist	
			
			
func eat(body : Node2D)->void:
	if(body.has_method('die')):
		body.die()
