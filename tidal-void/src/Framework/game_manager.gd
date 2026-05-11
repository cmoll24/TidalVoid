extends Node
class_name GameManager

@onready var sense_manager :SenseManager

#universal array of gravity sources
var gravity_sources : Array[GravitySource] = []

#universal array of shroud revealing sources
var revealing_sources : Array[Node2D] = []

var teleport_sources: Array[Node2D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_sources.assign(get_tree().get_nodes_in_group("gravity_sources"))
	sense_manager = $SenseManager
	#inventory_menu.hide()

func register_gravity_source(new_source: GravitySource) -> void:
	gravity_sources.append(new_source)
	
func unregister_gravity_source(source : GravitySource) -> void:
	gravity_sources.erase(source)	
	
func register_revealing_source(new_source: Node2D) -> void:
	revealing_sources.append(new_source)
	
func unregister_revealing_source(source : Node2D) -> void:
	revealing_sources.erase(source)	
	
func register_teleport_source(new_source: Node2D) -> void:
	teleport_sources.append(new_source)
func unregister_teleport_source(source: Node2D) -> void:
	teleport_sources.erase(source)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
		
static func orbital_velocity(source : GravitySource, pos : Vector2) -> Vector2:
	if not source:
		return Vector2.ZERO
	
	var to_source = source.global_position - pos
	var distance = to_source.length()
	var speed = sqrt((source.mass) / distance)
	return to_source.normalized().rotated(PI / 2.0) * speed	

static func escape_speed(source : GravitySource, pos : Vector2) -> float:
	if not source:
		return 0.0
	
	var to_source = source.global_position - pos
	var distance = to_source.length()
	#v_esc = sqrt(2*mu / r)
	var esc_speed = sqrt((2 * source.mass) / distance)
	return esc_speed
