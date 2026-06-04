extends Control
class_name UpgradeBuildWidget

var upgrade_resource : base_upgrade
var cost_item_name : String
var cost_quantity : int

@onready var buy_button : Button = $BuildButton
@onready var name_text : RichTextLabel = $Name
@onready var image : TextureRect = %UpgradeImage
@onready var desc_text : RichTextLabel = $Desc
@onready var req_res_text : RichTextLabel = $ReqResources
@onready var missing_res_text : RichTextLabel = $MissingResources

func set_upgrade_info(upgrade_name: String, upgrade_desc: String, item_name: String, quantity: int, upgrade: base_upgrade, upgrade_image: Texture2D) -> void:
	upgrade_resource = upgrade
	cost_item_name = item_name
	cost_quantity = quantity
	name_text.text = upgrade_name
	desc_text.text = upgrade_desc
	image.texture = upgrade_image
	var req_res : String = "Requires: %d %s" % [quantity, item_name]
	req_res_text.text = req_res

func show_missing(inventory : BaseInventory):
	var num_missing : int = cost_quantity - inventory.get_item_count(cost_item_name)
	if num_missing <= 0:
		missing_res_text.text = ""
	else:
		missing_res_text.text = "Missing: %d %s" % [num_missing, cost_item_name]

func clear_missing():
	missing_res_text.text = ""