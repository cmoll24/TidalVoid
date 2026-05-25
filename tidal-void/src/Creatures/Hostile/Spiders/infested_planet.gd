extends Planet
class_name InfestedPlanet

#array of the locations of holes spiders can enter and exit (global positions)
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

### types of things it cares about in vision (bitmask), see VisionSource.gd
var v_types : int

### all visible vision sources
var v_sources : Array[VisionSource] = []

var v_exceptions : Array[RID] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	spiders_inside = max_spiders
	spider_respawn_timer.timeout.connect(respawn_spider)
	game_manager.sense_manager.vision_timer.timeout.connect(update_vision)

func update_vision():
	if(spiders_inside < 1):
		return #no point in a vision check if there are no spiders
	#perform a vision check
	v_sources = game_manager.sense_manager.check_vision(self,v_distance,v_types,v_exceptions)
	
	#update behavior based on the results of the check
	update_behavior()
	
func update_behavior():
	#if there are more things to hunt than spiders outside, deploy one
	if(v_sources.size() > spiders_outside):
		deploy_spider()
func deploy_spider():
	if(spiders_inside < 1):
		return #cannot deploy spiders if we have none
		
	#spawn a spider
	
	#WIP
	
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
