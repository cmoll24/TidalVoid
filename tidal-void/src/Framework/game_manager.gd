class_name GameManager
extends Node

#universal array of gravity sources
var gravity_sources : Array[GravitySource] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_sources.assign(get_tree().get_nodes_in_group("gravity_sources"))

func register_gravity_source(new_source: GravitySource) -> void:
	gravity_sources.append(new_source)
	
func unregister_gravity_source(source : GravitySource) -> void:
	gravity_sources.erase(source)	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
