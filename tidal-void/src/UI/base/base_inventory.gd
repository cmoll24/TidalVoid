extends Node
class_name BaseInventory

#emits whenever inventory gains or loses an item
signal inventory_changed
#emits whenever hidden inventory gains or loses an item
signal hidden_inventory_changed
@export var inventory_size: int = 20

var inventory_items: Array = []

#inventory items not shown in slots, used for things like looking at the number of creatures stored
var hidden_inventory_items : Array = []

# The ship's primary creature storage will set itself here when it is loaded
var creature_storage : CreatureStorage = null

func _ready() -> void:
	inventory_items.resize(inventory_size)
	
func set_hidden_inventory_to_creatures():
	if(creature_storage):
		var stored_creatures : Dictionary = creature_storage.get_stored_creatures()
		set_hidden_inventory(CreatureStorage.stored_creatures_to_items(stored_creatures))
	else:
		set_hidden_inventory([])
	
func set_hidden_inventory(new_items : Array):
	hidden_inventory_items = new_items
	hidden_inventory_changed.emit()

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
func remove_item(target_item : String, amount : int) -> void:
	for i in range(inventory_items.size()):
		if(!inventory_items[i]):
			continue
		if inventory_items[i].get('item_name') == target_item:
			inventory_items[i]["quantity"] -= amount
			if inventory_items[i]["quantity"] <= 0:
				inventory_items[i] = null
			inventory_changed.emit()
			return

#Use for upgrades and such, check if player have sufficient items, and return a bool value
func has_item(item_name: String, quantity: int,b_check_hidden_inventory : bool = false) -> bool:
	for i in range(inventory_items.size()):
		if inventory_items[i] != null and inventory_items[i]["item_name"] == item_name:
			return inventory_items[i]["quantity"] >= quantity
	if(b_check_hidden_inventory):
		for i in range(hidden_inventory_items.size()):
			if hidden_inventory_items[i] != null and hidden_inventory_items[i]["item_name"] == item_name:
				return hidden_inventory_items[i]["quantity"] >= quantity
	return false
	
#get the number of a certain itemg
func get_item_count(item_name: String, b_check_hidden_inventory : bool = false) -> int:
	for i in range(inventory_items.size()):
		if inventory_items[i] != null and inventory_items[i]["item_name"] == item_name:
			return inventory_items[i]["quantity"]
	if(b_check_hidden_inventory):
		for i in range(hidden_inventory_items.size()):
			if hidden_inventory_items[i] != null and hidden_inventory_items[i]["item_name"] == item_name:
				return hidden_inventory_items[i]["quantity"]
	return 0

#Resize inventory (could be useful for upgrade that increases inventory size)
func resize_inventory(new_size: int) -> void:
	inventory_items.resize(new_size)
	inventory_size = new_size
	inventory_changed.emit()

#Get all items in inventory
func get_items() -> Array:
	return inventory_items
