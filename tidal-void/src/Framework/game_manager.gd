extends Node
class_name GameManager

@onready var sense_manager :SenseManager

#universal array of gravity sources
var gravity_sources : Array[GravitySource] = []

var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_sources.assign(get_tree().get_nodes_in_group("gravity_sources"))
	player = get_tree().get_first_node_in_group("player")
	sense_manager = $SenseManager
	#inventory_menu.hide()

func register_gravity_source(new_source: GravitySource) -> void:
	gravity_sources.append(new_source)
	
func unregister_gravity_source(source : GravitySource) -> void:
	gravity_sources.erase(source)	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
		
