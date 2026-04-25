extends Control

@onready var icon = $background/icon
@onready var quantity = $background/quantity
@onready var detail = $detail
@onready var item_name = $detail/item_name
@onready var item_type = $detail/item_type
@onready var item_effect = $detail/item_effect
@onready var use_or_drop = $use_or_drop

var item = null

func _on_item_button_mouse_entered() -> void:
	#if there is item, then show detail panel
	if item != null:
		use_or_drop.visible = false
		detail.visible = true

func _on_item_button_mouse_exited() -> void:
	#hide the detail panel
	detail.visible = false


func _on_item_button_pressed() -> void:
	
	#turn on and off the use or drop panel
	if item != null:
		use_or_drop.visible = !use_or_drop.visible

func set_empty_slot():
	icon.texture = null
	quantity.text = ""

#creates a new item slot if there is item
func set_item_slot(new_item):
	
	#now item is a new item
	item = new_item
	#icon.texture = item["texture"]
	quantity.text = str(item["quantity"])
	print("quantity set")
	item_name.text = str(item["item_name"])
	print("item name set")
	item_type.text = str(item["item_type"])
	print("item type set")
	
	#if effect is present, set effect to that item's descrip
	if item["item_effect"] != "":
		item_effect.text = str("new ", item["item_effect"])
	else:
		item_effect.text = ""
	
	
