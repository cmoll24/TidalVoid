extends UIMenu

func _ready() -> void:
	print("UpgradeMenu _ready called, in tree: ", is_inside_tree())
	super._ready()  # keeps UIMenu's own _ready logic

func _on_open_upgrade_menu() -> void:
	print("upgrade menu received signal - toggling")
	toggle_pause()
	print("UpgradeMenu visible after toggle: ", visible)
