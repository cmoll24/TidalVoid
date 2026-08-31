class_name GlobalVariables
extends Node

var player_health = 100
var player_node: PlayerPawn = null
var player_HUD : PlayerHUD = null
var player_controller : PlayerController = null
@onready var inventory_slot_scene = preload("res://src/UI/inventory_ui/inventory_slot.tscn")

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
var player_inventory: PlayerInventory = null

signal inventory_update
signal open_upgrade_menu

# Defines the dictionary for creature for journal
var creature_button_dict = {
	Creature.crafting_type.jeremiah: {
		"asset": "res://assets/Textures/Creatures/jeremiah.png",
		"found": false,
		"name": "Jeremiah",
		"story": "A small prey creature, uses limited thrust to catch food in orbit",
		"adapt": "Tentacles aid in fruit collection",
		"diet": "Fruitarian",
		"behavior": "Passive to just about everything, a harmless creature"
	},
	Creature.crafting_type.steven: {
		"asset": "res://assets/Textures/Creatures/magnetbigspike.png",
		"found": false,
		"name": "Steven",
		"story": "A small prey creature, uses limited thrust to catch food in orbit",
		"adapt": "Spikes deter predation",
		"diet": "Fruitarian",
		"behavior": "Orbits to collect fruit, passive, yet also dangerous enough to have no natural predators"
	},
	Creature.crafting_type.leaper: {
		"asset": "res://assets/Textures/Creatures/leaper.png",
		"found": false,
		"name": "Leaper",
		"story": "A organism more flora than fauna. Spends the majority of a lifetime passively growing before jumping to other planets to spread.",
		"adapt": "The leaper has adapted to use energy sparingly",
		"diet": "Have no idea, been watching it for 100 hours and it's just been jumping in place",
		"behavior": "It umm, leaps"
	},
	Creature.crafting_type.evil_fred: {
		"asset": "res://assets/Textures/Creatures/evil_fred_move.png",
		"found": false,
		"name": "Evil Fred",
		"story": "A moderately sized predator, tends to live in foggy areas, capable of orbital movement",
		"adapt": "Unique mouth aids in full capture of prey",
		"diet": "Carnivorous",
		"behavior": "Spends the majority of time in hibernation, waiting for prey to get close."
	},
	Creature.crafting_type.charlotte: {
		"asset": "res://assets/Textures/Creatures/charlotte.png",
		"found": false,
		"name": "Charlotte",
		"story": "A small predator, lives in colonies built under the surface of planets, capable of both walking and orbiting",
		"adapt": "Burrowing protects against radiation, Web production aids in hunting",
		"diet": "Carnivorous",
		"behavior": "Fires webs from a distance in an effort to knock prey out of orbit. Once prey has been grounded,
		walks quickly on the surface to consume it."
	},
	Creature.crafting_type.hungry_harry: {
		"asset": "res://assets/Textures/Placeholder/PLACEHOLDER_WormHead.png",
		"found": false,
		"name": "Hungry Harry",
		"story": "A large predator, lives within large planets in particulary hot areas",
		"adapt": "Burrowing protects against radiation, Capable of surviving immense heat",
		"diet": "Carnivorous and Lithovorous",
		"behavior": "Lives in constant motion, slowing eating planets. Shifts to face prey that gets within range."
	},
	Creature.crafting_type.star_ray: {
		"asset": "res://assets/Textures/Creatures/star_mantaray.png",
		"found": false,
		"name": "Star Ray",
		"story": "********************",
		"adapt": "*********************************",
		"diet": "********",
		"behavior": "*************************************************************"
	}
}

var upgrade_info = {
	Head1 = {
		title = "Teleport",
		description = "Let's you teleport home.",
		items = [
		{name ='Methane Clathrate', quantity = 10},
		{name = 'Nickel Ore', quantity = 10},
		{name = "Jeremiah", quantity = 1}],
		resource = preload('res://src/upgrades_effects/upgrades/abilities/teleport_upgrade.tres'),
		unlocked = false
	},
	Head2 = {
		title = "Head 2",
		description = "It's Head Upgrade 2",
		items = []
	},
	Head3 = {
		title = "Head 3",
		description = "It's Head Upgrade 3",
		items = []
	},
	Body1 = {
		title = "Overdrive",
		description = "Currently Teleport because I needed to test things...\nUnlocks and equips overdrive thrusters, fireable by pressing 3. On use, thrusters become significantly more powerful for a short time. Can be fired 10 times before requiring a recharge at the reset terminal on the ship.",
		items = [
		{name ='Methane Clathrate', quantity = 2},
		{name = 'Nickel Ore', quantity = 3},
		{name = 'Charlotte', quantity = 2}],
		resource = preload('res://src/upgrades_effects/upgrades/abilities/overdrive_thruster_upgrade.tres'),
		unlocked = false
	},
	Body2 = {
		title = "Pulse Shield",
		description = "Unlocks and equips the pulse shield, fireable by pressing 4. The pulse shield provides temporary protection from damage. Can be fired 5 times before requiring a recharge at the reset terminal on the ship.",
		items = [
		{name ='Copper Ore', quantity = 4},
		{name = 'Methane Clathrate', quantity = 1},
		{name = 'Basalt', quantity = 2},
		{name = 'Steven', quantity = 1}],
		resource = preload('res://src/upgrades_effects/upgrades/abilities/pulse_shield_upgrade.tres'),
		unlocked = false
	},
	Leg1 = {
		title = "Impulse Thrusters",
		description = "Unlocks and equips impulse thrusters, fireable by pressing 1. Impulse thrusters provide an instant velocity boost in the direction the mouse. Can be fired 5 times before requiring a recharge at the reset terminal on the ship.",
		items = [
		{name = "Methane Clathrate", quantity = 3},
		{name = "Basalt", quantity = 1},
		{name = "Jeremiah", quantity = 1}],
		resource = preload('res://src/upgrades_effects/upgrades/abilities/impulse_thruster_upgrade.tres'),
		unlocked = false
	},
	Leg2 = {
		title = "Leg 2",
		description = "It's Leg Upgrade 2",
		items = []
	},
}

func discover_creature(creature_type : Creature.crafting_type):
	if not creature_button_dict[creature_type]["found"]:
		
		creature_button_dict[creature_type]["found"] = true
		player_HUD.create_toast("You discovered a creature!")

func _ready():
	#Create player inventory instance
	player_inventory = PlayerInventory.new()
	add_child(player_inventory)
	
	# onnect inventory signal to global signal
	player_inventory.inventory_changed.connect(_on_inventory_changed)
	
	load_from_save_file = load_game()
	
func _on_inventory_changed() -> void:
	inventory_update.emit()

func add_item(items) -> bool:
	return player_inventory.add_item(items)
	
func remove_item(target_item : String, quantity : int) -> void:
	player_inventory.remove_item(target_item,quantity)
			
func set_player_reference(player : PlayerPawn):
	player_node = player

func set_HUD_reference(HUD : PlayerHUD):
	player_HUD = HUD

func set_player_controller_ref(controller : PlayerController):
	player_controller = controller
	
func has_item(item_name: String, quantity: int) -> bool:
	return player_inventory.has_item(item_name, quantity)
	
func get_inventory() -> Array:
	return player_inventory.get_items()


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
