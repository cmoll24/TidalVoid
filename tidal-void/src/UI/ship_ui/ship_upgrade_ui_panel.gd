extends UIPanel
class_name ShipUpgradePanel

var game_manager : GameManager

var inventory : BaseInventory

var build_widget_scene = preload("res://src/UI/ship_ui/upgrade_build_widget.tscn")

var upgrade_table : Array[Dictionary] = [
	{
		upgrade_name = 'Impulse thrusters',
		upgrade_desc = 'Unlocks and equips impulse thrusters, fireable by pressing 1. Impulse thrusters provide an instant velocity boost in the direction the mouse.
		Can be fired 5 times before requiring a recharge at the reset terminal on the ship.',
		upgrade_cost = [{item_name ='Methane Clathrate',quantity = 3},
		{item_name = 'Basalt',quantity = 1},
		{item_name = 'Jeremiah',quantity = 1}],
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/abilities/impulse_thruster_upgrade.tres'),
		image = preload('res://assets/Textures/Placeholder/Thick_Jim.png')
	},
	{
		upgrade_name = 'Overdrive',
		upgrade_desc = 'Unlocks and equips overdrive thrusters, fireable by pressing 3. On use, thrusters become significantly more powerful for a short time.
		Can be fired 10 times before requiring a recharge at the reset terminal on the ship.',
		upgrade_cost = [{item_name ='Methane Clathrate',quantity = 2},
		{item_name = 'Nickel Ore',quantity = 3},
		{item_name = 'Charlotte',quantity = 2}],
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/abilities/overdrive_thruster_upgrade.tres'),
		image = preload('res://assets/Textures/Placeholder/Thick_Jim.png')
	},
	{
		upgrade_name = 'Pulse Shield',
		upgrade_desc = 'Unlocks and equips the pulse shield, fireable by pressing 4. The pulse shield provides temporary protection from damage.
		Can be fired 5 times before requiring a recharge at the reset terminal on the ship.',
		upgrade_cost = [{item_name ='Copper Ore',quantity = 4},
		{item_name = 'Methane Clathrate',quantity = 1},
		{item_name = 'Basalt',quantity = 2},
		{item_name = 'Steven',quantity = 1}],
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/abilities/pulse_shield_upgrade.tres'),
		image = preload('res://assets/Textures/Player/CreatureCarrier_bubble.png')
	},
]

@onready var upgrade_entries : VBoxContainer = $ScrollContainer/UpgradeEntries

func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")
	unpack_upgrade_table()
	call_deferred("_post_ready")

func _post_ready():
	inventory = GV.player_inventory

	await get_tree().process_frame

func unpack_upgrade_table():
	for entry in upgrade_table:
		var widget : UpgradeBuildWidget = build_widget_scene.instantiate()
		upgrade_entries.add_child(widget)

	await get_tree().process_frame

	for i in range(upgrade_table.size()):
		var widget : UpgradeBuildWidget = upgrade_entries.get_child(i)
		#explictly set the type of the upgrade cost(godot crashes otherwise, spagetti code)
		var upgrade_price : Array[Dictionary]
		upgrade_price.assign(upgrade_table[i]['upgrade_cost']);
		widget.set_upgrade_info(
			upgrade_table[i]['upgrade_name'],
			upgrade_table[i]['upgrade_desc'],
			upgrade_price,
			upgrade_table[i]['upgrade_resource'],
			upgrade_table[i]['image']
		)
		widget.buy_button.pressed.connect(try_buy_upgrade.bind(
			upgrade_table[i]['upgrade_name'],
			upgrade_table[i]['upgrade_resource'],
			upgrade_price,
			widget
		))

func try_buy_upgrade(upgrade_name: String, upgrade: base_upgrade, upgrade_cost : Array[Dictionary], widget: UpgradeBuildWidget) -> bool:
	for price_item in upgrade_cost:
		if !inventory.has_item(price_item['item_name'],price_item['quantity'],true):
			#if we are missing something, return false, show what is missing
			widget.show_missing(inventory)
			return false

	#subtract the price
	for price_item in upgrade_cost:
		inventory.remove_item(price_item['item_name'],price_item['quantity'])
	upgrade.apply_effect(GV.player_node)
	print("You purchased %s!" % upgrade_name)
	widget.clear_missing()
	return true
