extends ShipTerminal

func on_player_interact(player : Player) -> void:
	player.reset_abilities()
	print("Reset Player Abilities")
