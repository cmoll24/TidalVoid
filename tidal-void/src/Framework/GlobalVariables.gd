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

# Defines the dictionary for creature for journal
var creature_button_dict = {
	"creature1": {
		"asset": "res://assets/Textures/Placeholder/Evil_Fred.png",
		"found": false,
		"name": "Evil Fred",
		"story": "Fred...But not good",
		"adapt": "Normally we see Fred as good, but they're in space now, so they adapted to be evil",
		"diet": "Surpisingly a pretty healthy diet...except for the mushrooms...the bad ones",
		"behavior": "We say he's evil, but he's acts like Fred except he doesn't recycle"
	},
	"creature2": {
		"asset": "res://assets/Textures/Placeholder/floater.png",
		"found": false,
		"name": "Floater",
		"story": "Never gonna guess what it does",
		"adapt": "I think it was a rock that wanted to prove it's other rock friends wrong. Please read Land of the Lusterous",
		"diet": "Microbes or something I think",
		"behavior": "You'll really never guess what it does"
	},
	"creature3": {
		"asset": "res://assets/Textures/Placeholder/Jeremy.png",
		"found": false,
		"name": "Jermey",
		"story": "You are not worthy enough for their story",
		"adapt": "Not worthy",
		"diet": "Nuhuh, ask them",
		"behavior": "Look Jermey is a good guy, literally go up and say hi, you can learn this from them yourself"
	},
	"creature4": {
		"asset": "res://assets/Textures/Placeholder/leaper.png",
		"found": false,
		"name": "Leaper",
		"story": "*Insert the floater joke here*",
		"adapt": "I think this was a bunch of worms that didn't want to be in the ground anymore, or an octopus",
		"diet": "Have no idea, been watching it for 100 hours and it's just been jumping in place",
		"behavior": "You get the joke"
	},
	"creature5": {
		"asset": "res://assets/Textures/Placeholder/Thick_Jim.png",
		"found": false,
		"name": "Thick Jim",
		"story": "Jim...but ate a little to much Arby's",
		"adapt": "Looks like he ended up this way because finals were coming up and he kept snacking (also Arby's)",
		"diet": "Salad, yeah, he's really trying to slim down",
		"behavior": "Jogs every morning, goes to the gym after doing work, pretty normal guy"
	},
	"creature6": {
		"asset": "res://assets/Textures/Placeholder/astronaut.png",
		"found": false,
		"name": "Astronaut",
		"story": "Oh shiii- that me",
		"adapt": "With this treasure, I summon Eight-Handled Sword Divergent Sila Divine General Mahoraga",
		"diet": "Panda Express, yeah I don't want to cook",
		"behavior": "Crying at 12:47 AM on the dot, every day"
	},
	"creature7": {
		"asset": "res://assets/Textures/Placeholder/cookie.png",
		"found": false,
		"name": "Cookie",
		"story": "It's...a cookie...",
		"adapt": "What do you want, it's a cookie",
		"diet": "...They can't eat...",
		"behavior": "Look, if you can show me a cookie can do things on it's own, that 5 bucks for you"
	},
	"creature8": {
		"asset": "res://assets/circle.png",
		"found": false,
		"name": "Circle",
		"story": "ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE",
		"adapt": "The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly but gets faster each minute after you hear this signal bodeboop. A sing lap should be completed every time you hear this sound. ding Remember to run in a straight line and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark. Get ready!… Start. ",
		"diet": "Your Mother",
		"behavior": "Stealing Social Security Numbers"
	}
}

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
