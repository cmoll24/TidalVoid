extends Control

# Preload panel scenes because this will be first scene that opens up
var inventory_panel_scene = preload("res://src/UI/inventory_ui/InventoryPanel.tscn")
# var journal_panel_scene = preload("res://src/UI/panels/journal_panel.tscn")

#References to UI elements
@onready var inventory_button = $PanelContainer/VBoxContainer/TabBar/InventoryButton
@onready var journal_button = $PanelContainer/VBoxContainer/TabBar/JournalButton
@onready var body_row = $PanelContainer/VBoxContainer/BodyRow
@onready var health_lable = $"../HealthLable"

var current_panel: UIPanel = null

func _ready() -> void:
	hide()
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	journal_button.pressed.connect(_on_journal_button_pressed)

func _process(_delta: float) -> void:
	health_lable.text = str(GV.player_health) + " HP"

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

#how journal panel
func _on_journal_button_pressed() -> void:
	#TO DO THIS IS NOT IMPLEMENTED YET!!!
	print("Journal button pressed - panel not implemented yet")

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
