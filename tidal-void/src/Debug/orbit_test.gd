extends Node2D

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var health_lable = $CanvasLayer/HealthLable
@onready var inventory_ui = $CanvasLayer/Inventory

func _ready():
	inventory_ui.hide()

func _process(_delta: float) -> void:
	#open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	health_lable.text = str(GV.player_health) + " HP"
	
