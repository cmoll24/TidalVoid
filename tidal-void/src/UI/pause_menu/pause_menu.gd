extends UIMenu

@onready var inventory_button = $PanelContainer/VBoxContainer/TabBar/InventoryButton

func _input(event: InputEvent) -> void:
	super._input(event)
	if event.is_action_pressed("inventory"):
		toggle_pause()

#Open pause menu and show inventory by default
func open_menu() -> void:
	super.open_menu()
	
	#Show inventory panel by default
	inventory_button._on_pressed()
