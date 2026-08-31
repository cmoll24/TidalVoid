extends Button
class_name UpgradeButton

@export var button_dict_name: String = "None"
@export var button_icon: Texture2D
@export var debug_text: String
signal upgrade_clicked(upgrade_type: String)

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	if button_icon:
		icon = button_icon
		
	if debug_text:
		text = debug_text
	
func _on_pressed() -> void:
	upgrade_clicked.emit(button_dict_name)
