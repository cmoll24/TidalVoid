extends ShipTerminal

func on_player_interact() -> void:
	if(GV.player_node):
		GV.player_controller.toolbar.reset_abilities()
	print("Reset Player Abilities")
