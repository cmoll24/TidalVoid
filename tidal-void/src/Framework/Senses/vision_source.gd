extends Node
class_name VisionSource
#You must name this VisionSource and place it as a direct child of 
#the root in any scene instance for it to work

### Enum used for giving information about the type of source
enum v_source_type {None,sPrey,mPrey,lPrey,sPred,mPred,LPred,sFood}


@onready var parent : Node2D

### registers this vision source with the sense manager on game start
@export var b_register_on_start : bool = true

### describes what it is, influences AI behavior towards the owner of the source
@export var v_type : v_source_type = v_source_type.sFood

var game_manager : GameManager



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent();
	if(b_register_on_start):
		game_manager = get_tree().get_first_node_in_group("game_managers");
		game_manager.sense_manager.register_vision_source(self)

func _exit_tree() -> void:
	game_manager.sense_manager.unregister_vision_source(self)		
		
	
