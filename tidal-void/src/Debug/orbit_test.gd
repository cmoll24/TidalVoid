extends Node2D
class_name OrbitTest

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var health_lable = $CanvasLayer/HealthLabel
@onready var pause_menu = $CanvasLayer/PauseMenu

@onready var time_label = $CanvasLayer/TimeLabel

func _ready():
	pause_menu.hide()

func _process(_delta: float) -> void:
	#open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	if(GV.player_node):
		health_lable.text = "%.2f" % GV.player_node.health_comp.health + " HP"
	time_label.text = str(GV.save_data["play_time"] + (Time.get_ticks_msec() / 1000))



func not_suspicious_function():
	for i in range(10000):
		print('one hundred million crabs no.%s' % randi())
