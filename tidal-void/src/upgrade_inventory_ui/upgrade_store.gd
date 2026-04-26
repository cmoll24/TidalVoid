extends Control

@onready var store_grid = $StoreGrid
@onready var back_button = $BackButton

@export var available_upgrades: Array[upgrade_store_item] = []

var store_slot_scene = preload("res://src/upgrade_inventory_ui/upgrade_store_slot.tscn")

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	populate_store()

func populate_store():
	for upgrade in available_upgrades:
		var slot = store_slot_scene.instantiate()
		store_grid.add_child(slot)
		slot.set_store_item(upgrade)

func _on_back_button_pressed():
	visible = false
	get_parent().get_node("Inventory").visible = true
