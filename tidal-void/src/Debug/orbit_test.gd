extends Node2D
class_name OrbitTest

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var health_lable = $CanvasLayer/HealthLable
@onready var pause_menu = $CanvasLayer/PauseMenu

@onready var time_label = $CanvasLayer/TimeLabel

func _ready():
	pause_menu.hide()

func _process(_delta: float) -> void:
	#open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	health_lable.text = str(GV.player_health) + " HP"
	time_label.text = str(GV.save_data["play_time"] + (Time.get_ticks_msec() / 1000))
