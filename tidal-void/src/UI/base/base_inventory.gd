extends Node
class_name BaseInventory

#emits whenever
signal inventory_changed
@export var inventory_size: int = 20

var inventory_items: Array = []

func _ready() -> void:
	inventory_items.resize(inventory_size)

#For add item, check if the name and effect matches. If yes, then we increase it's quantity
func add_item(item: Dictionary) -> bool:
	for i in range(inventory_items.size()):
		if inventory_items[i] != null and inventory_items[i]["item_name"] == item["item_name"] and inventory_items[i]["item_effect"] == item["item_effect"]:
			inventory_items[i]["quantity"] += item["quantity"]
			inventory_changed.emit()
			return true
	
	#If it's the case that there's no such item in inventory, then we make it occupy a slot
	for i in range(inventory_items.size()):
		if inventory_items[i] == null:
			inventory_items[i] = item
			inventory_changed.emit()
			return true
	
	#If inventory is full, return false
	return false

#Remove_item uses similar logic as add item
func remove_item(target_item) -> void:
	for i in range(inventory_items.size()):
		if inventory_items[i] == target_item:
			inventory_items[i]["quantity"] -= 1
			if inventory_items[i]["quantity"] <= 0:
				inventory_items[i] = null
			inventory_changed.emit()
			return

#Use for upgrades and such, check if player have sufficient items, and return a bool value
func has_item(item_name: String, quantity: int) -> bool:
	for i in range(inventory_items.size()):
		if inventory_items[i] != null and inventory_items[i]["item_name"] == item_name:
			return inventory_items[i]["quantity"] >= quantity
	return false

#Resize inventory (could be useful for upgrade that increases inventory size)
func resize_inventory(new_size: int) -> void:
	inventory_items.resize(new_size)
	inventory_size = new_size
	inventory_changed.emit()

#Get all items in inventory
func get_items() -> Array:
	return inventory_items
