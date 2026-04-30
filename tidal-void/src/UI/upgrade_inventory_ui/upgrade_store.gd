extends Control

@onready var store_grid = $StoreGrid
@onready var back_button = $BackButton

#lists of uprgade store item resources assigned in inspector
@export var available_upgrades: Array[upgrade_store_item] = []

var store_slot_scene = preload("res://src/UI/upgrade_inventory_ui/upgrade_store_slot.tscn")

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	#populates the store with all available upgrade when starting
	populate_store()
	
	
func populate_store():
	print("upgrade count: ", available_upgrades.size())
	for upgrade in available_upgrades:
		#creates new slot instance for this upgrade
		#add it to the grid, and pass data to slot for displays
		var slot = store_slot_scene.instantiate()
		store_grid.add_child(slot)
		slot.set_store_item(upgrade)
		print("slot added, child count: ", store_grid.get_child_count())
		
		
func _on_back_button_pressed():
	#hides store and make inventory visible
	get_parent().show_inventory()
