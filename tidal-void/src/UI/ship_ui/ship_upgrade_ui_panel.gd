extends UIPanel
class_name ShipUpgradePanel

var game_manager : GameManager

var inventory : BaseInventory

var build_widget_scene = preload("res://src/UI/ship_ui/upgrade_build_widget.tscn")

var upgrade_table : Array[Dictionary] = [
	{
		upgrade_name = 'Health Boost',
		upgrade_desc = 'Increases maximum health by 25 and heals the same amount.',
		cost_item_name = 'Copper Ore',
		cost_quantity = 1,
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/health_upgrade.tres'),
		image = preload('res://assets/Textures/Placeholder/SunDLC.png')
	},
	{
		upgrade_name = 'Speed Boost',
		upgrade_desc = 'Increases movement speed for better mobility.',
		cost_item_name = 'Copper Ore',
		cost_quantity = 1,
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/double_grapple.tres'),
		image = preload('res://assets/Textures/Placeholder/SunDLC.png')
	},
	{
		upgrade_name = 'Double Grapple',
		upgrade_desc = 'Doubles your grapple charges.',
		cost_item_name = 'Copper Ore',
		cost_quantity = 1,
		upgrade_resource = preload('res://src/upgrades_effects/upgrades/double_grapple.tres'),
		image = preload('res://assets/Textures/Placeholder/SunDLC.png')
	}
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
		var widget = upgrade_entries.get_child(i)
		widget.set_upgrade_info(
			upgrade_table[i]['upgrade_name'],
			upgrade_table[i]['upgrade_desc'],
			upgrade_table[i]['cost_item_name'],
			upgrade_table[i]['cost_quantity'],
			upgrade_table[i]['upgrade_resource'],
			upgrade_table[i]['image']
		)
		widget.buy_button.pressed.connect(try_buy_upgrade.bind(
			upgrade_table[i]['upgrade_name'],
			upgrade_table[i]['upgrade_resource'],
			upgrade_table[i]['cost_item_name'],
			upgrade_table[i]['cost_quantity'],
			widget
		))

func try_buy_upgrade(upgrade_name: String, upgrade: base_upgrade, cost_item_name: String, cost_quantity: int, widget: UpgradeBuildWidget) -> bool:
	if !inventory.has_item(cost_item_name, cost_quantity):
		widget.show_missing(inventory)
		return false

	inventory.remove_item(cost_item_name, cost_quantity)
	upgrade.apply_effect(GV.player_node)
	print("You purchased %s!" % upgrade_name)
	widget.clear_missing()
	return true