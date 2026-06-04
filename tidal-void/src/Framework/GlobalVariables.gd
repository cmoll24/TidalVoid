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
	"creature1": {
		"asset": "res://assets/Textures/Creatures/jeremiah.png",
		"found": false,
		"name": "Jeremiah",
		"story": "A small prey creature, uses limited thrust to catch food in orbit",
		"adapt": "Tentacles aid in fruit collection",
		"diet": "Fruitarian",
		"behavior": "Passive to just about everything, a harmless creature"
	},
	"creature2": {
		"asset": "res://assets/Textures/Creatures/magnetbigspike.png",
		"found": false,
		"name": "Steven",
		"story": "A small prey creature, uses limited thrust to catch food in orbit",
		"adapt": "Spikes deter predation",
		"diet": "Fruitarian",
		"behavior": "Orbits to collect fruit, passive, yet also dangerous enough to have no natural predators"
	},
	"creature3": {
		"asset": "res://assets/Textures/Creatures/leaper.png",
		"found": false,
		"name": "Leaper",
		"story": "A organism more flora than fauna. Spends the majority of a lifetime passively growing before jumping to other planets to spread.",
		"adapt": "The leaper has adapted to use energy sparingly",
		"diet": "Have no idea, been watching it for 100 hours and it's just been jumping in place",
		"behavior": "It umm, leaps"
	},
	"creature4": {
		"asset": "res://assets/Textures/Creatures/evil_fred_move.png",
		"found": false,
		"name": "Evil Fred",
		"story": "A moderately sized predator, tends to live in foggy areas, capable of orbital movement",
		"adapt": "Unique mouth aids in full capture of prey",
		"diet": "Carnivorous",
		"behavior": "Spends the majority of time in hibernation, waiting for prey to get close."
	},
	"creature5": {
		"asset": "res://assets/Textures/Creatures/charlotte.png",
		"found": false,
		"name": "Charlotte",
		"story": "A small predator, lives in colonies built under the surface of planets, capable of both walking and orbiting",
		"adapt": "Burrowing protects against radiation, Web production aids in hunting",
		"diet": "Carnivorous",
		"behavior": "Fires webs from a distance in an effort to knock prey out of orbit. Once prey has been grounded,
		walks quickly on the surface to consume it."
	},
	"creature6": {
		"asset": "res://assets/Textures/Placeholder/PLACEHOLDER_WormHead.png",
		"found": false,
		"name": "Hungry Harry",
		"story": "A large predator, lives within large planets in particulary hot areas",
		"adapt": "Burrowing protects against radiation, Capable of surviving immense heat",
		"diet": "Carnivorous and Lithovorous",
		"behavior": "Lives in constant motion, slowing eating planets. Shifts to face prey that gets within range."
	},
	"creature7": {
		"asset": "res://assets/Textures/Placeholder/Evil_Fred.png",
		"found": false,
		"name": "Evil Fred",
		"story": "Fred...But not good",
		"adapt": "Normally we see Fred as good, but they're in space now, so they adapted to be evil",
		"diet": "Surpisingly a pretty healthy diet...except for the mushrooms...the bad ones",
		"behavior": "We say he's evil, but he's acts like Fred except he doesn't recycle"
	},
	"creature8": {
		"asset": "res://assets/Textures/Placeholder/Jeremy.png",
		"found": false,
		"name": "Jermey",
		"story": "You are not worthy enough for their story",
		"adapt": "Not worthy",
		"diet": "Nuhuh, ask them",
		"behavior": "Look Jermey is a good guy, literally go up and say hi, you can learn this from them yourself"
	},
	"creature9": {
		"asset": "res://assets/Textures/Placeholder/Thick_Jim.png",
		"found": false,
		"name": "Thick Jim",
		"story": "Jim...but ate a little to much Arby's",
		"adapt": "Looks like he ended up this way because finals were coming up and he kept snacking (also Arby's)",
		"diet": "Salad, yeah, he's really trying to slim down",
		"behavior": "Jogs every morning, goes to the gym after doing work, pretty normal guy"
	},
	"creature10": {
		"asset": "res://assets/Textures/Placeholder/astronaut.png",
		"found": false,
		"name": "Astronaut",
		"story": "Oh shiii- that me",
		"adapt": "With this treasure, I summon Eight-Handled Sword Divergent Sila Divine General Mahoraga",
		"diet": "Panda Express, yeah I don't want to cook",
		"behavior": "Crying at 12:47 AM on the dot, every day"
	},
	"creature11": {
		"asset": "res://assets/Textures/Placeholder/cookie.png",
		"found": false,
		"name": "Cookie",
		"story": "It's...a cookie...",
		"adapt": "What do you want, it's a cookie",
		"diet": "...They can't eat...",
		"behavior": "Look, if you can show me a cookie can do things on it's own, that 5 bucks for you"
	},
	"creature12": {
		"asset": "res://assets/circle.png",
		"found": false,
		"name": "Circle",
		"story": "ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE, ALL HAIL THE CIRCLE",
		"adapt": "The FitnessGram Pacer Test is a multistage aerobic capacity test that progressively gets more difficult as it continues. The 20 meter pacer test will begin in 30 seconds. Line up at the start. The running speed starts slowly but gets faster each minute after you hear this signal bodeboop. A sing lap should be completed every time you hear this sound. ding Remember to run in a straight line and run as long as possible. The second time you fail to complete a lap before the sound, your test is over. The test will begin on the word start. On your mark. Get ready!… Start. ",
		"diet": "Your Mother",
		"behavior": "Stealing Social Security Numbers"
	}
}

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
