extends Control

@onready var upgrade_name_label = $background/upgrade_name
@onready var description_label = $background/description
@onready var cost_label = $background/cost
@onready var buy_button = $background/buy_button
@onready var insufficient_label = $background/insufficient  # hidden by default

var store_item: upgrade_store_item = null

func set_store_item(new_store_item: upgrade_store_item):
	store_item = new_store_item
	upgrade_name_label.text = store_item.upgrade_name
	description_label.text = store_item.description
	cost_label.text = str(store_item.cost_quantity) + "x " + store_item.cost_item_name

func _on_buy_button_pressed() -> void:
	if store_item == null:
		return
	

	if GV.has_item(store_item.cost_item_name, store_item.cost_quantity):
		GV.remove_item_by_name(store_item.cost_item_name, store_item.cost_quantity)
		store_item.upgrade.apply_effect(GV.player_node)
		print("Purchased: ", store_item.upgrade_name)
		insufficient_label.visible = false
	else:
		insufficient_label.visible = true
		print("Not enough resources!")
