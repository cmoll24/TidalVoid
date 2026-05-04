extends Control
 
@onready var store_grid = $PanelContainer/VBoxContainer/BodyRow/ScrollContainer/StoreGrid
@onready var inventory_tab = $PanelContainer/VBoxContainer/TabBar/InventoryTab
 
# List of upgrade store item resources assigned in inspector
@export var available_upgrades: Array[upgrade_store_item] = []
 
var store_slot_scene = preload("res://src/UI/upgrade_inventory_ui/upgrade_store_slot.tscn")
 
func _ready():
	assert(store_grid != null, "StoreGrid not found — make sure upgrade_store.tscn is the new version with the inventory shell")
	assert(inventory_tab != null, "InventoryTab not found — make sure upgrade_store.tscn is the new version with the inventory shell")
	inventory_tab.pressed.connect(_on_inventory_tab_pressed)
	populate_store()
 
func populate_store():
	for upgrade in available_upgrades:
		var slot = store_slot_scene.instantiate()
		store_grid.add_child(slot)
		slot.set_store_item(upgrade)
		
func _on_inventory_tab_pressed():
	get_parent().show_inventory()
