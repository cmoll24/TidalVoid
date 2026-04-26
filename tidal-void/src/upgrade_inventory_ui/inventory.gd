extends Control

@onready var grid_container = $GridContainer

func _ready():
	# GV function signal to update inventory UI
	GV.inventory_update.connect(_on_inventory_update)
	_on_inventory_update()
	
func _on_inventory_update():
	clear_grid()
	#instantiate the slot in the inventory scene
	for item in GV.inventory:
		var slot = GV.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		
		#if there are no item when creating the slot, we make a empty slot
		if item != null:
			slot.set_item_slot(item)
		else:
			slot.set_empty_slot()

#Clears grid first to update the item
func clear_grid():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
	
