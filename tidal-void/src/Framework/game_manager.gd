extends Node
class_name GameManager

@onready var sense_manager :SenseManager

@onready var inventory_menu = get_node("/root/OrbitTestScene/CanvasLayer/Inventory")
var paused = false

#universal array of gravity sources
var gravity_sources : Array[GravitySource] = []

var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_sources.assign(get_tree().get_nodes_in_group("gravity_sources"))
	player = get_tree().get_first_node_in_group("player")
	sense_manager = $SenseManager
	inventory_menu.hide()

func register_gravity_source(new_source: GravitySource) -> void:
	gravity_sources.append(new_source)
	
func unregister_gravity_source(source : GravitySource) -> void:
	gravity_sources.erase(source)	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		inventory_open()
		
func inventory_open():
	
	# If already paused, then resume
	if paused:
		inventory_menu.hide()
		Engine.time_scale = 1
	
	# Else attempt to pause
	else:
		inventory_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
