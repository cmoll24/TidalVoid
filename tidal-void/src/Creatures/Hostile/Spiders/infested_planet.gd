extends Planet
class_name InfestedPlanet

#array of the locations of holes spiders can enter and exit (local positions(translated to global during runtime))
@export var spider_holes : Array[Vector2]

@export var max_spiders : int = 5
###the number of spiders currently in the planet 
var spiders_inside : int = 5
###the number of spiders currently outside the planet
var spiders_outside : int = 0

### the infested planet looks out for prey and deploys spiders when it is close
### the max distance at which things can be seen by vision
@export var v_distance : float = 1200

@onready var spider_respawn_timer : Timer = $SpiderRespawnTimer

#square altitude at which spiders will stay on ground to wait for prey instead of jumping (should be larger than square collision radius)
@export var stay_grounded_altitude_sqr = 60000;

### types of things it cares about in vision (bitmask), see VisionSource.gd
var v_types : int

### all visible vision sources
var v_sources : Array[VisionSource] = []

var v_exceptions : Array[RID] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#set vision mask
	
	#initialize values
	spiders_inside = max_spiders
	#setup timers
	spider_respawn_timer.timeout.connect(respawn_spider)
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)
	#convert hole locations to global space
	for i in range(spider_holes.size()):
		spider_holes[i] = to_global(spider_holes[i])
		
	#set the v mask
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)
	v_exceptions.append(self)

func update_vision():
	if(spiders_inside < 1):
		return #no point in a vision check if there are no spiders
	#perform a vision check
	v_sources = game_manager.sense_manager.check_vision(self,v_distance,v_types,v_exceptions)
	
	#update behavior based on the results of the check
	update_behavior()
	
func update_behavior():
	
	#save performance, don't bother checking anything if there are no spiders
	if(spiders_inside < 1):
		return;
	var v_source_num : int = v_sources.size() 
	#if there are more things to hunt than spiders outside, deploy one
	if(v_source_num > spiders_outside):
		deploy_spider()
	else:
		#deploy extra spiders if prey gets close to the planet
		for v in v_sources:
			if(v.parent.global_position.distance_squared_to(global_position) < stay_grounded_altitude_sqr):
				deploy_spider();
				break;
		
func deploy_spider():
	if(spiders_inside < 1):
		return #cannot deploy spiders if we have none
		
	#spawn a spider
	var spider : Charlotte= preload("res://src/Creatures/Hostile/Spiders/charlotte.tscn").instantiate()
	spider.global_position = spider_holes[randi_range(0,spider_holes.size() - 1)];
	get_tree().root.add_child(spider)
	
	#update spider counts
	spiders_inside -= 1
	spiders_outside += 1
	
func respawn_spider():
	#respawn a spider inside if some have died
	#Note, does not actually spawn anything, merely lets the planet know it a spawn more spiders when the time comes
	if(max_spiders < spiders_outside + spiders_inside):
		spiders_inside+=1;

func save() -> Dictionary:
	var node_data : Dictionary = {
		in_spiders = spiders_inside,
		out_spiders = spiders_outside
	}
	return node_data
	
func load_state(node_data :Dictionary):
	spiders_inside = node_data['in_spiders']
	spiders_outside = node_data['out_spiders']
