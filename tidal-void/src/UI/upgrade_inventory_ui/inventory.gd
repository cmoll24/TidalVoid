extends Control

@onready var grid_container  = $PanelContainer/VBoxContainer/BodyRow/GridContainer
@onready var scroll_container = $PanelContainer/VBoxContainer/BodyRow/ScrollContainer
@onready var store_grid       = $PanelContainer/VBoxContainer/BodyRow/ScrollContainer/StoreGrid
@onready var inventory_tab    = $PanelContainer/VBoxContainer/TabBar/InventoryTab
@onready var upgrades_button  = $PanelContainer/VBoxContainer/TabBar/UpgradesButton

@export var available_upgrades: Array[upgrade_store_item] = []

var store_slot_scene = preload("res://src/UI/upgrade_inventory_ui/upgrade_store_slot.tscn")

func _ready():
	# GV function signal to update inventory UI
	GV.inventory_update.connect(_on_inventory_update)
	_on_inventory_update()
	
	inventory_tab.pressed.connect(_show_inventory_view)
	upgrades_button.pressed.connect(_show_upgrades_view)
	
	populate_store()
	
	_show_inventory_view()
	
func _show_inventory_view():
	grid_container.show()
	scroll_container.hide()
 
func _show_upgrades_view():
	print("_show_upgrades_view called")
	grid_container.hide()
	scroll_container.show()
	
func populate_store():
	for upgrade in available_upgrades:
		var slot = store_slot_scene.instantiate()
		store_grid.add_child(slot)
		slot.set_store_item(upgrade)
	
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
	
