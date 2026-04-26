extends Node

var player_health = 100
var player_node: Node = null
@onready var inventory_slot_scene = preload("res://src/upgrade_inventory_ui/inventory_slot.tscn")

# where our inventory item goes
var inventory = []
signal inventory_update

func _process(_delta):
	pass

func _ready():
	# our default size of inventory is 20
	inventory.resize(20)


func add_item(items):
	for i in range(inventory.size()):
		#if item exit in inventory AND it matches the name and effect type
		if inventory[i] != null and inventory[i]["item_name"] == items["item_name"] and inventory[i]["item_effect"] == items["item_effect"]:
			#updates the quantity
			inventory[i]["quantity"] += items["quantity"]
			inventory_update.emit()
			return true
		#if item does not exist, then we make a new one
		elif inventory[i] == null:
			inventory[i] = items
			inventory_update.emit()
			return true
			
		inventory_update.emit()
	
func remove_item(target_item):
	# goes thru items 0 - 19
	for i in range(inventory.size()):
		# find the matching item
		if inventory[i] == target_item:
			# subtract quantity by 1
			inventory[i]["quantity"] -= 1
			# if less than 0, then null it
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			# updates inventory after
			inventory_update.emit()
			return
	
func player_reference(player):
	player_node = player
	
