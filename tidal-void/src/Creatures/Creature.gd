extends TextureRect

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var screen_pos = game_manager.player.get_global_transform_with_canvas().origin
	var viewport_size = get_viewport().get_visible_rect().size
	var player_uv = screen_pos / viewport_size
	material.set_shader_parameter("player_screen_uv", player_uv);
