extends Node2D
class_name TeleportPosition

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group('game_managers')
	game_manager.register_teleport_source(self)
