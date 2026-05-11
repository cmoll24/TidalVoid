extends Control

@onready var body_grid = $PanelContainer/VBoxContainer/BodyRow/ScrollContainer/GridContainer
@onready var inventory_tab = $PanelContainer/VBoxContainer/TabBar/InventoryTab
@onready var upgrades_button = $PanelContainer/VBoxContainer/TabBar/UpgradesButton

@export var available_upgrades: Array[upgrade_store_item] = []

var store_slot_scene = preload("res://src/UI/upgrade_inventory_ui/upgrade_store_slot.tscn")

var current_view = "inventory"

func _ready():
	# GV function signal to update inventory UI
	GV.inventory_update.connect(_on_inventory_update)
	inventory_tab.pressed.connect(_show_inventory_view)
	upgrades_button.pressed.connect(_show_upgrades_view)
	
	# grid starts empty
	_show_inventory_view()
	
func _show_inventory_view():
	current_view = "inventory"
	body_grid.columns = 10
	_on_inventory_update()
 
func _show_upgrades_view():
	current_view = "upgrades"
	body_grid.columns = 1
	clear_body_grid()
	populate_store()
	
func populate_store():
	for upgrade in available_upgrades:
		var slot = store_slot_scene.instantiate()
		body_grid.add_child(slot)
		slot.set_store_item(upgrade)
	
func _on_inventory_update():
	# Only update if the inventory tab is currently open
	if current_view != "inventory": #do nothing if inventory is not opened
		return
	clear_body_grid() #wipe whateve is in the grid
	for item in GV.inventory:
		var slot = GV.inventory_slot_scene.instantiate()
		body_grid.add_child(slot)
		if item != null:
			slot.set_item_slot(item)
		else:
			slot.set_empty_slot()

# Clears grid first to update the item
func clear_body_grid():
	while body_grid.get_child_count() > 0:
		# It takes index 0 bce after each removal what was index 1 becomes the new index 0
		# so this works through every slot
		var child = body_grid.get_child(0)
		body_grid.remove_child(child)
		child.queue_free()
	
