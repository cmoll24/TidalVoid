extends Node

var player_health = 100
var player_node: Node = null
@onready var inventory_slot_scene = preload("res://src/upgrade_inventory_ui/inventory_slot.tscn")


var inventory = []

signal inventory_update

func _ready():
	#size of inventory = 20
	inventory.resize(20)


func add_item(items):
	for i in range(inventory.size()):
		#if item exit in inventory AND it matches the name and effect type
		if inventory[i] != null and inventory[i]["item_name"] == items["item_name"] and inventory[i]["item_effect"] == items["item_effect"]:
			#updates the quantity
			inventory[i]["item_quantity"] += items["item_quantity"]
			inventory_update.emit()
			return true
		#if item does not exist, then we make a new one
		elif inventory[i] == null:
			inventory[i] = items
			inventory_update.emit()
			return true
			#if neither then dont add it into the inventory
			
			# FROM ORIGINAL TUTORIAL ----> return false
			
		inventory_update.emit()
	
func remove_item():
	inventory_update.emit()
	
func player_reference(player):
	player_node = player
	
