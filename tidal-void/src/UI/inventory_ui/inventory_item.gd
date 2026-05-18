extends Collectable
class_name InventoryItem

#declare all the item properties and export them to editor
@export var item_type = ""
@export var item_effect = ""
@export var item_name = ""
@export var item_texture : Texture

#this creates place to select different upgrades for items
@export var effect: base_item_effect
var scene_path = "res://src/UI/upgrade_inventory_ui/inventory_item.tscn"
@onready var icon_sprite = $Sprite2D

# for checking if player is in inventory body
var player_spotted = false

func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture

#holds attributes for picked-up inventory items
func pick_up_item():
	var items = {
		"quantity" = 1,
		"item_type" = item_type,
		"item_effect" = item_effect,
		"item_name" = item_name,
		"item_texture" = item_texture,
		"scene_path" = scene_path,
		"effect" = effect,
	}
	#calls add item when player is trying to add items, and queue_free the item 
	print("pick up item called")
	print("GV player node: ", GV.player_node)
	if GV.player_node:
		
		#here GV.add_item is called to let base_inventory know to add item
		GV.add_item(items)
		self.queue_free()
		
func _on_body_entered_inventory(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player spotted")
		pick_up_item()
