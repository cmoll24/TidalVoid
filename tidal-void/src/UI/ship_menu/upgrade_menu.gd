extends UIMenu

@onready var upgrade_panel: ShipUpgradePanel = $PanelContainer/VBoxContainer/BodyRow/ShipUpgradeUiPanel
@onready var description_box: VBoxContainer = $PanelContainer/ItemDescription/VBoxContainer
@onready var upgrade_title: RichTextLabel = $PanelContainer/ItemDescription/VBoxContainer/UpgradeTitle
@onready var upgrade_description: RichTextLabel = $PanelContainer/ItemDescription/VBoxContainer/ScrollContainer/UpgradeDescription
@onready var equip_button: Button = $PanelContainer/ItemDescription/VBoxContainer/Button

# The upgrade currently shown to user as a string (Dictionary name)
var current_upgrade_shown

# Holds strings to keep track of what equipment is currently equipped
# Index 0 is for the head, 1 is for the body, and 2 is for the legs
var current_equipment = ["None", "None", "None"]

func _ready() -> void:
	# Sets the description box (left box) to not visible
	description_box.visible = false
	# Gives this var an initial value
	current_upgrade_shown = "None"
		
	# Connects the upgrade buttons
	for button in get_tree().get_nodes_in_group("upgrade_buttons"):
		if button is Button:
			button.upgrade_clicked.connect(upgrade_clicked)
			
	# Debug function to give me items
	dumb_way_to_get_items()

func open_menu() -> void:
	super.open_menu()
	#update the hidden inventory
	GV.player_inventory.set_hidden_inventory_to_creatures()
	
	if upgrade_panel:
		upgrade_panel.open_panel()

func close_menu() -> void:
	hide()
	description_box.visible = false
	get_tree().paused = false
	if upgrade_panel:
		upgrade_panel.close_panel()
		
func upgrade_clicked(upgrade_type: String) -> void:	
	# If not showing an upgrade, show it
	if description_box.visible == false:
		description_box.visible = true
	
	# Switch info to the info of upgrade button clicked
	if upgrade_type != current_upgrade_shown:
		current_upgrade_shown = upgrade_type
		set_upgrade_info(upgrade_type)
		set_equip_button()
	
func set_upgrade_info(upgrade_type: String) -> void:
	# Sets title of Upgrade in ItemDescription
	upgrade_title.text = "[b]" + GV.upgrade_info[upgrade_type]["title"] + "[/b]"
	
	# Initialize the info string for ItemDescription
	var final_string = ""

	# Create the description of the upgrade
	final_string += GV.upgrade_info[upgrade_type]["description"]
	final_string += "\n\n"
	
	# If Have not unlocked upgrade, add items needed to craft and items owned
	if !GV.upgrade_info[upgrade_type]["unlocked"]:
		var item_list = GV.upgrade_info[upgrade_type]["items"]
		var required_item_string = "[b]Required: [/b]\n"
		var missing_items_string = "[b]Owned Materials: [/b]\n"
		
		for item in item_list:
			required_item_string += (item["name"] + ": " + str(item["quantity"]) + "\n")
			
			var item_name = item['name']
			var player_item_count = GV.player_inventory.get_item_count(item_name, true)
			var num_missing : int = item['quantity'] - player_item_count
			if num_missing <= 0:
				missing_items_string += ("[color=#1a7d11]" + item["name"] + ": " + str(player_item_count) + "[/color]\n")
			else:
				missing_items_string += ("[color=red]" + item["name"] + ": " + str(player_item_count) + "[/color]\n")
			
		final_string += required_item_string + "\n"
		final_string += missing_items_string
	
	# Set the description to the final string
	upgrade_description.text = final_string
	
# Sets text for buying/equipping upgrades
func set_equip_button() -> void:
	var upgrade_dict = GV.upgrade_info[current_upgrade_shown]
	
	# If not unlocked, set to Buy
	if !upgrade_dict["unlocked"]:
		equip_button.text = "Buy"
		return
	
	var shown_upgrade_slot = upgrade_dict["resource"].ability_slot
	var shown_upgrade_name = upgrade_dict["title"]
	
	# Else set to either equipped or equip depending if upgrade active
	if shown_upgrade_name != current_equipment[shown_upgrade_slot]:
		equip_button.text = "Equip"
	else:
		equip_button.text = "Equipped"
	
# Function that runs when clicking Buy/Equip
func equip_buy_upgrade() -> void:
	var upgrade_dict = GV.upgrade_info[current_upgrade_shown]
	var upgrade = upgrade_dict["resource"]
	var upgrade_cost = upgrade_dict["items"]
	
	# If upgrade not unlocked, see if we can unlock it
	if !upgrade_dict["unlocked"]:
		for item in upgrade_cost:
			if !GV.player_inventory.has_item(item["name"], item["quantity"], true):
				return
					
		for item in upgrade_cost:
			await GV.player_inventory.remove_item(item["name"], item["quantity"])
			
		GV.upgrade_info[current_upgrade_shown]["unlocked"] = true
		set_upgrade_info(current_upgrade_shown)
		
	# Equip the current upgrade
	
	# IMPORTANT: Might need to just add the basic boost
	# to the upgrade dict to access and use it to slot in the ability
	# and de equip it. Also make that slot "None" in the equipped array
	var ability_slot = upgrade.ability_slot
	if current_equipment[ability_slot] != upgrade_dict["title"]:
		current_equipment[ability_slot] = upgrade_dict["title"]
		upgrade.apply_effect(GV.player_node)
	else:
		current_equipment[ability_slot] = "None"
		upgrade.remove_effect(GV.player_node)
	
	set_equip_button()
	
# Debug Function, can delete	
func dumb_way_to_get_items() -> void:
	var copper = {
		"quantity" = 10,
		"item_type" = "Ore",
		"item_effect" = "",
		"item_name" = "Copper Ore",
		"item_texture" = "res://.godot/imported/Copper_Ore.png-ffa897cb4105e7e106f023feaa7670b7.ctex",
		"scene_path" = "res://src/UI/upgrade_inventory_ui/inventory_item.tscn",
		"effect" = "res://src/Collectables/Ores/copper_ore.tscn::Resource_cgyau"
	}
	
	var methane = {
		"quantity" = 10,
		"item_type" = "Ore",
		"item_effect" = "",
		"item_name" = "Methane Clathrate",
		"item_texture" = "res://.godot/imported/Methane_Clathrate.png-e6c01d73fcde0544b80e6715ca3fdfe7.ctex",
		"scene_path" = "res://src/UI/upgrade_inventory_ui/inventory_item.tscn",
		"effect" = "res://src/Collectables/Ores/methane_clathrate.tscn::Resource_cgyau"
	}
	
	var basalt = {
		"quantity" = 10,
		"item_type" = "Ore",
		"item_effect" = "",
		"item_name" = "Basalt",
		"item_texture" = "res://.godot/imported/Basalt_Ore.png-ab5c4df914ad64219fd468afddac6ab1.ctex",
		"scene_path" = "res://src/UI/upgrade_inventory_ui/inventory_item.tscn",
		"effect" = "res://src/Collectables/Ores/basalt.tscn::Resource_cgyau"
	}
	
	var nickel = {
		"quantity" = 10,
		"item_type" = "Ore",
		"item_effect" = "",
		"item_name" = "Nickel Ore",
		"item_texture" = "res://.godot/imported/Nickel_Ore.png-816f017ebfe5be4a6a6bc6f7407960b7.ctex",
		"scene_path" = "res://src/UI/upgrade_inventory_ui/inventory_item.tscn",
		"effect" = "res://src/Collectables/Ores/nickel_ore.tscn::Resource_cgyau"
	}
	
	GV.add_item(copper)
	GV.add_item(methane)
	GV.add_item(basalt)
	GV.add_item(nickel)
	
