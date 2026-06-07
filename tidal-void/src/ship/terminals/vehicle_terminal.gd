extends ShipTerminal

func on_player_interact() -> void:
	#open the menu one frame later so it does not detect the interact event as closing
	GV.player_HUD.vehicle_menu.call_deferred('open_menu')
