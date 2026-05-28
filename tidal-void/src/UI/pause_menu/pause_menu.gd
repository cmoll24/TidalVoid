extends Control

# Preload panel scenes because this will be first scene that opens up
var inventory_panel_scene = preload("res://src/UI/inventory_ui/InventoryPanel.tscn")
var journal_panel_scene = preload("res://src/UI/journal_ui/journal_menu.tscn")
var TEMP_vehicle_panel_scene = preload("res://src/UI/ship_ui/ship_vehicle_ui_panel.tscn")

#References to UI elements
@onready var inventory_button = $PanelContainer/VBoxContainer/TabBar/InventoryButton
@onready var journal_button = $PanelContainer/VBoxContainer/TabBar/JournalButton

@onready var TEMP_vehicle_button = $PanelContainer/VBoxContainer/TabBar/TEMP_VehicleButton

@onready var body_row = $PanelContainer/VBoxContainer/BodyRow

var current_panel: UIPanel = null

func _ready() -> void:
	hide()
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	journal_button.pressed.connect(_on_journal_button_pressed)
	TEMP_vehicle_button.pressed.connect(_TEMP_on_vehicle_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_pause()

func toggle_pause() -> void:
	if visible:
		close_pause_menu()
	else:
		open_pause_menu()
		
#Open pause menu and show inventory by default
func open_pause_menu() -> void:
	show()
	get_tree().paused = true
	
	#Show inventory panel by default
	_show_panel(inventory_panel_scene)

#Close pause menu
func close_pause_menu() -> void:
	hide()
	get_tree().paused = false
	
	#Clear current panel
	if current_panel != null:
		_clear_panel()

#Show inventory panel
func _on_inventory_button_pressed() -> void:
	_show_panel(inventory_panel_scene)

#show journal panel
func _on_journal_button_pressed() -> void:
	_show_panel(journal_panel_scene)
	
#show vehicle panel
func _TEMP_on_vehicle_button_pressed() -> void:
	_show_panel(TEMP_vehicle_panel_scene)

func _show_panel(panel_scene: PackedScene) -> void:
	#Clear existing panel
	_clear_panel()
	
	#Instantiate new panel
	current_panel = panel_scene.instantiate()
	body_row.add_child(current_panel)
	current_panel.open_panel()

#Clear current panel from body row
func _clear_panel() -> void:
	if current_panel != null:
		current_panel.close_panel()
		body_row.remove_child(current_panel)
		current_panel.queue_free()
		current_panel = null
