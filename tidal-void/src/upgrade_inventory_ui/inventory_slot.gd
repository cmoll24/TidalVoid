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

#default empty slots
func set_empty_slot():
	icon.texture = null
	quantity.text = ""

#creates a new item slot if there is item
func set_item_slot(new_item):
	
	#now item is a new item
	item = new_item
	icon.texture = item["item_texture"]
	quantity.text = str(item["quantity"])
	item_name.text = str(item["item_name"])
	item_type.text = str(item["item_type"])

	
	# f effect is present, set effect to that item's descrip
	if item["item_effect"] != "":
		item_effect.text = str(item["item_effect"])
	else:
		item_effect.text = ""
	
# using the inventory item to apply upgrade to the user
func _on_use_button_pressed() -> void:
	# if item is there
	if item != null:
		# get the upgrade
		var upgrade = item.get("upgrade")
		# if upgrade is there
		if upgrade != null:
			# applies the effect
			upgrade.apply_effect(GV.player_node)
		# remove after use
		GV.remove_item(item)
