extends UIMenu

@onready var upgrade_panel: ShipUpgradePanel = $PanelContainer/VBoxContainer/BodyRow/ShipUpgradeUiPanel

func _ready() -> void:
	super._ready()

func open_menu() -> void:
	super.open_menu()
	if upgrade_panel:
		upgrade_panel.open_panel()

func close_menu() -> void:
	hide()
	get_tree().paused = false
	if upgrade_panel:
		upgrade_panel.close_panel()
