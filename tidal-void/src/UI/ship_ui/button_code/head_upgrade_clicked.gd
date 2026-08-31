extends UpgradeButton

signal upgrade_clicked(upgrade_type: String)

func _ready() -> void:
	super._ready()
	
func _on_pressed() -> void:
	upgrade_clicked.emit(button_dict_name)
