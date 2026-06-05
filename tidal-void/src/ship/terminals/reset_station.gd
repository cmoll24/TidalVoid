extends ShipTerminal

func on_player_interact() -> void:
	if(GV.player_node):
		GV.player_controller.toolbar.reset_abilities()
		GV.player_HUD.create_toast("Reset Player Abilities")
	print("Reset Player Abilities")
