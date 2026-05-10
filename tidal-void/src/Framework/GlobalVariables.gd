class_name GlobalVariables
extends Node

var player_health = 100
var player_node: PlayerPawn = null
@onready var inventory_slot_scene = preload("res://src/UI/upgrade_inventory_ui/inventory_slot.tscn")

const SAVE_PATH = "user://save.json"

var load_from_save_file = false

var save_data: Dictionary = {
	#player state
	"player_position": {"x" : 0.0, "y" : 0.0},
	"player_velocity": {"x" : 0.0, "y" : 0.0},
	
	#meta
	"save_version": 1,
	"play_time": 0.0
}

# where our inventory item goes
var inventory = []
signal inventory_update

func _process(_delta):
	pass

func _ready():
	# our default size of inventory is 20
	inventory.resize(20)
	
	load_from_save_file = load_game()

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
	
func player_reference(player : PlayerPawn):
	player_node = player
	
func has_item(item_name: String, quantity: int) -> bool:
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["item_name"] == item_name:
			return inventory[i]["quantity"] >= quantity
	return false

func remove_item_by_name(item_name: String, quantity: int):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["item_name"] == item_name:
			inventory[i]["quantity"] -= quantity
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_update.emit()
			return


## SAVE LOGIC

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Save failed: " +  str(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	
	print("Saved ", str(save_data))

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	
	if result != OK:
		push_error("Save file corrupted")
	
	var loaded = json.get_data()
	
	print(loaded)
	
	#Check save file version
	if loaded.get("save_version", 0) < save_data["save_version"]:
		print("This is an old save file")
		#we can mitigate issues here, but for now we do nothing
	
	for key in save_data:
		if loaded.has(key):
			save_data[key] = loaded[key]
	
	return true

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("deubg_save"):
		save_data["player_position"]["x"] = player_node.global_position.x
		save_data["player_position"]["y"] = player_node.global_position.y
		
		save_data["player_velocity"]["x"] = player_node.velocity.x
		save_data["player_velocity"]["y"] = player_node.velocity.y
		
		var time_played : int =  Time.get_ticks_msec() / 1000
		save_data["play_time"] += time_played
		save_game()
	
	elif event.is_action("debug_delete_save"):
		delete_save()
