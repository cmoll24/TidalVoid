extends Control
class_name UIMenu

@onready var tab_bar = $PanelContainer/VBoxContainer/TabBar
@onready var body_row = $PanelContainer/VBoxContainer/BodyRow

var current_panel: UIPanel = null

func _ready() -> void:
	hide()
	
	for node in tab_bar.get_children():
		if node is PanelButton:
			node.open_panel.connect(_show_panel)

func toggle_pause() -> void:
	if visible:
		close_pause_menu()
	else:
		open_pause_menu()

#Open pause menu and show inventory by default
func open_pause_menu() -> void:
	show()
	get_tree().paused = true

#Close pause menu
func close_pause_menu() -> void:
	hide()
	get_tree().paused = false
	
	#Clear current panel
	if current_panel != null:
		_clear_panel()

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
