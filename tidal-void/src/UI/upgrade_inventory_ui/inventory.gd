extends Control

@onready var grid_container = $GridContainer
@onready var upgrades_button = $UpgradesButton

func _ready():
	# GV function signal to update inventory UI
	GV.inventory_update.connect(_on_inventory_update)
	_on_inventory_update()
	upgrades_button.pressed.connect(_on_upgrades_button_pressed)
	
func _on_upgrades_button_pressed():
	get_parent().show_upgrade_store()
	
func _on_inventory_update():
	# we clear grid first, update the new inventory list, and put them back in
	clear_grid()
	#instantiate the slot in the inventory scene
	for item in GV.inventory:
		var slot = GV.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		
		if item != null:
			slot.set_item_slot(item)
		# if there are no item when creating the slot, we make a empty slot
		else:
			slot.set_empty_slot()

# Clears grid first to update the item
func clear_grid():
	while grid_container.get_child_count() > 0:
		# It takes index 0 bce after each removal what was index 1 becomes the new index 0
		# so this works through every slot
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
	
