extends Control
class_name ShipVehicleBuildWidget

var spawn_path : String

var price : Array[Dictionary]

@onready var build_button : Button = $BuildButton

@onready var name_text : RichTextLabel = $Name

@onready var image : TextureRect = %VehicleImage

@onready var desc_text : RichTextLabel = $Desc

@onready var req_res_text : RichTextLabel = $ReqResources

@onready var missing_res_text : RichTextLabel = $MissingResources


func _ready() -> void:
	pass

### sets all values of the widget to display its information
### does not update missing resources
func set_vehicle_info(vehicle_path : String,
vehicle_price : Array[Dictionary],
vehicle_name : String,
vehicle_desc : String,
vehicle_image):
	#directly set values
	spawn_path = vehicle_path
	price = vehicle_price
	name_text.text = vehicle_name
	desc_text.text = vehicle_desc
	image.texture = vehicle_image
	#make a string for the req_res_text
	var req_res : String = "Requires: "
	for i in range(price.size()):
		req_res += ("%s " % price[i]['quantity']) + price[i]['item_name']
		if(i < price.size() - 1):
			req_res += ", "
	req_res_text.text = req_res
	
func update_missing_resources(inventory : BaseInventory):
	#make a string for the missing res text
	var missing_res : String = "Missing: "
	for i in range(price.size()):
		var item_name : String = price[i]['item_name']
		var num_missing : int = price[i]['quantity'] - inventory.get_item_count(item_name)
		if(num_missing <= 0): #only positive values are missing
			continue;
		missing_res += ("%s " % num_missing) + item_name 
		if(i < price.size() - 1):
			missing_res  += ", "
	missing_res_text.text = missing_res 
