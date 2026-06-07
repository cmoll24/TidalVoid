extends UIMenu

@onready var inventory_button = $PanelContainer/VBoxContainer/TabBar/InventoryButton
@onready var journal_button = $PanelContainer/VBoxContainer/TabBar/JournalButton

var b_start_in_inventory : bool = true

func _input(event: InputEvent) -> void:
	super._input(event)
	#open, starting in inventory
	if event.is_action_pressed("inventory"):
		b_start_in_inventory = true
		toggle_pause()
	#open, starting in journal
	elif event.is_action_pressed("journal"):
		b_start_in_inventory = false
		toggle_pause()

#Open pause menu and show inventory by default
func open_menu() -> void:
	super.open_menu()
	
	#Show inventory panel or journal panel depending on start_in_inventory
	if(b_start_in_inventory):
		inventory_button._on_pressed()
	else:
		journal_button._on_pressed()
