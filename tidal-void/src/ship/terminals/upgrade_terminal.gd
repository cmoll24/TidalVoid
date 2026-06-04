extends ShipTerminal

@export var upgrade_menu_scene: PackedScene

func on_player_interact() -> void:
	print("terminal interacted - emitting open_upgrade_menu")
	# If menu doesn't exist yet, create it
	if not has_node("UpgradeMenu"):
		var menu = upgrade_menu_scene.instantiate()
		menu.name = "UpgradeMenu"
		add_child(menu)
		
		get_node("UpgradeMenu").toggle_pause()
