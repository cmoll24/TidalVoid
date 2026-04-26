extends Node2D

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var inventory_ui = $CanvasLayer/Inventory

func _ready():
	inventory_ui.hide()

func _process(_delta: float) -> void:
	open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	
func open_inventory():
	if Input.is_action_just_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		print("inventory_opened")
