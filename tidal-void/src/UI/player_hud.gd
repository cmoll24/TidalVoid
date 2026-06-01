extends CanvasLayer
class_name PlayerHUD

@onready var pause_menu : UIMenu = $PauseMenu
@onready var vehicle_menu : UIMenu = $VehicleMenu

@onready var fps_label = $FPSLabel
@onready var health_lable = $HealthLabel

@onready var time_label = $TimeLabel

func _ready() -> void:
	GV.set_HUD_reference(self)

func _process(_delta: float) -> void:
	#open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	if(GV.player_node):
		health_lable.text = "%.2f" % GV.player_node.health_comp.health + " HP"
	time_label.text = str(GV.save_data["play_time"] + (Time.get_ticks_msec() / 1000))
