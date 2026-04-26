extends Control

@onready var store_grid = $StoreGrid
@onready var back_button = $BackButton
@export var available_upgrades: Array[upgrade_store_item] = []

var store_slot_scene = preload("res://src/upgrade_inventory_ui/upgrade_store_slot.tscn")

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	populate_store()

func populate_store():
	print("populate_store called")
	print("store_grid: ", store_grid)
	print("upgrade count: ", available_upgrades.size())
	
	for upgrade in available_upgrades:
		var slot = store_slot_scene.instantiate()
		store_grid.add_child(slot)
		slot.set_store_item(upgrade)
		print("slot added, child count: ", store_grid.get_child_count())

func _on_back_button_pressed():
	visible = false
	get_parent().get_node("Inventory").visible = true
