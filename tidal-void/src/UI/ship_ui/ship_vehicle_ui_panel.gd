extends UIPanel
class_name ShipVehiclePanel

var game_manager : GameManager

var inventory : BaseInventory

var build_widget_scene = preload("res://src/UI/ship_ui/ship_vehicle_build_widget.tscn")

var vehicle_table : Array[Dictionary]= [
	{
		vehicle_name = 'Creature Carrier',
		vehicle_desc = 'A small craft, applications in the transport and capture of specimens.',
		path = 'res://src/player/Equipment/creature_carrier.tscn',
		price = [{'item_name' : 'Copper Ore', 'quantity' : 3}],
		image = preload('res://assets/Textures/Player/CreatureCarrier_body.png')
	}
	
]

@onready var vehicle_entries : VBoxContainer = $ScrollContainer/VehicleEntries

func _ready() -> void:
	#get the game manager reference
	game_manager = get_tree().get_first_node_in_group("game_managers")

	#unpack the vehicle table to construct the ui
	unpack_vehicle_table()
	
	#setup call to post ready
	call_deferred("_post_ready")
	
	
#called one frame after ready
func _post_ready():
	#get the inventory
	inventory = GV.player_inventory
	
	#connect signals
	
	inventory.inventory_changed.connect(update_deficiency_numbers)
	
	await get_tree().process_frame
	
	#update missing resources
	
	update_deficiency_numbers()
	
func unpack_vehicle_table():
	#spawn all the widgets
	for entry in vehicle_table:
		var widget : ShipVehicleBuildWidget = build_widget_scene.instantiate()
		vehicle_entries.add_child(widget)
	
	#wait till next frame
	await get_tree().process_frame
		
	#set the values
	for i in range(vehicle_table.size()):
		#explictly set the type of price(godot crashes otherwise, spagetti code)
		var price : Array[Dictionary]
		price.assign(vehicle_table[i]['price'])
		#set the info
		var widget = vehicle_entries.get_child(i)
		widget.set_vehicle_info(vehicle_table[i]['path'],price,vehicle_table[i]['vehicle_name'],vehicle_table[i]['vehicle_desc'],vehicle_table[i]['image'])
		widget.build_button.pressed.connect(try_build_vehicle.bind(vehicle_table[i]['path'],price))
#updates the "missing x resource" numbers to reflect the player's inventory
func update_deficiency_numbers():
	if !visible:
		return #avoid wasteful updates
		
	#update the numbers on all build widgets
	for child in vehicle_entries.get_children():
		child.update_missing_resources(inventory)
	
### the scene path is a path to vehicle to be spawned
### the price is an array of dictionaries of the form {'item_name','quantity'}
### returns false if a vehicle could not be built
func try_build_vehicle(scene_path : String,price : Array[Dictionary]):
	#check that the inventory meets the price
	for price_item in price:
		if !inventory.has_item(price_item['item_name'],price_item['quantity']):
			#if we are missing something, return false
			return false
	#if price is met, spawn the ship
	game_manager.ship_manager.spawn_vehicle(scene_path)
	#now take the price
	for price_item in price:
		inventory.remove_item(price_item['item_name'],price_item['quantity'])
	return true
	
