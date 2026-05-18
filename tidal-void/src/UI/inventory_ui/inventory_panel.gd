extends UIPanel
class_name InventoryPanel

@onready var body_grid = $ScrollContainer/GridContainer

func _ready() -> void:
	#Connect to inventory updates
	GV.inventory_update.connect(_refresh_inventory)
	_refresh_inventory()

func _refresh_inventory() -> void:
	_clear_grid()
	
	var inventory = GV.get_inventory()
	print("Inventory size: ", inventory.size())
	print("Inventory contents: ", inventory)
	
	var slot_count = 0
	
	for item in inventory:
		var slot = GV.inventory_slot_scene.instantiate()
		body_grid.add_child(slot)
		slot_count += 1
		
		if item != null:
			slot.set_item_slot(item)
		else:
			slot.set_empty_slot()
			
	print("Successfully instantiated ", slot_count, " slots into the grid.")

#Clear all items from grid
func _clear_grid() -> void:
	for child in body_grid.get_children():
		body_grid.remove_child(child)
		child.queue_free()
