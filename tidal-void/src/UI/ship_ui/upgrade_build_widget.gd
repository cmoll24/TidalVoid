extends Control
class_name UpgradeBuildWidget

var upgrade_resource : base_upgrade
var upgrade_price : Array[Dictionary]

@onready var buy_button : Button = $BuildButton
@onready var name_text : RichTextLabel = $Name
@onready var image : TextureRect = %UpgradeImage
@onready var desc_text : RichTextLabel = $Desc
@onready var req_res_text : RichTextLabel = $ReqResources
@onready var missing_res_text : RichTextLabel = $MissingResources

func set_upgrade_info(upgrade_name: String, upgrade_desc: String,  upgrade_cost : Array[Dictionary], upgrade: base_upgrade, upgrade_image: Texture2D) -> void:
	upgrade_resource = upgrade
	upgrade_price = upgrade_cost
	name_text.text = upgrade_name
	desc_text.text = upgrade_desc
	image.texture = upgrade_image
	var req_res : String = 'Requires: '
	for i in range(upgrade_cost.size()):
		req_res += ("%s " % upgrade_cost[i]['quantity']) + upgrade_cost[i]['item_name']
		if(i < upgrade_cost.size() - 1):
			req_res += ", "
	req_res_text.text = req_res

func show_missing(inventory : BaseInventory):
	#make a string for the missing res text
	var missing_res : String = "Missing: "
	for i in range(upgrade_price.size()):
		var item_name : String = upgrade_price[i]['item_name']
		var num_missing : int = upgrade_price[i]['quantity'] - inventory.get_item_count(item_name,true)
		if(num_missing <= 0): #only positive values are missing
			continue;
		missing_res += ("%s " % num_missing) + item_name 
		if(i < upgrade_price.size() - 1):
			missing_res  += ", "
	missing_res_text.text = missing_res 

func clear_missing():
	missing_res_text.text = ""
