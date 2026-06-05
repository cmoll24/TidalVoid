extends ShipTerminal

func on_player_interact() -> void:
	#Heal and reset abilities
	if(GV.player_node):
		GV.player_controller.toolbar.reset_abilities()
		GV.player_node.health_comp.set_health(GV.player_node.health_comp.max_health)
		GV.player_HUD.create_toast("Reset Player Abilities")
	print("Reset Player Abilities")
