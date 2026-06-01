extends Button
class_name PanelButton

@export var panel_scene : PackedScene

signal open_panel(scene)

func _on_pressed() -> void:
	open_panel.emit(panel_scene)
