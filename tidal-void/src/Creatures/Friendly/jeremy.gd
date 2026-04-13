extends TextureRect

var game_manager : GameManager

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")

func _process(delta: float) -> void:
	pass
