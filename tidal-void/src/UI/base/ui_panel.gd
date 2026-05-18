extends Control
class_name UIPanel


signal panel_opened
signal panel_closed

func open_panel() -> void:
	visible = true
	panel_opened.emit()

func close_panel() -> void:
	visible = false
	panel_closed.emit()
