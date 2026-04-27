extends Control

# variables for describing the upgrade's attribute
@onready var upgrade_name_label = $background/upgrade_name
@onready var description_label = $background/description
@onready var cost_label = $background/cost
@onready var buy_button = $background/buy_button
@onready var insufficient_label = $background/insufficient

var store_item: upgrade_store_item = null

func _ready():
	insufficient_label.visible = false

#this is called by upgrade_store.gd when instantiating slots
#we can populate the UI with data from given reousrce
func set_store_item(new_store_item: upgrade_store_item):
	store_item = new_store_item
	#creates name and descript
	upgrade_name_label.text = store_item.upgrade_name
	description_label.text = store_item.description
	#use x for how many item it requires
	cost_label.text = str(store_item.cost_quantity) + "x " + store_item.cost_item_name


func _on_buy_button_pressed() -> void:
	#do nothing if its empty slot
	if store_item == null:
		return
	
	#make sure player has enough item
	if GV.has_item(store_item.cost_item_name, store_item.cost_quantity):
		# deduct quantity from item
		GV.remove_item_by_name(store_item.cost_item_name, store_item.cost_quantity)
		# applies said effect
		store_item.upgrade.apply_effect(GV.player_node)
		insufficient_label.visible = false
	#insufficient lable only shows when not enough item
	else:
		insufficient_label.visible = true
