extends CanvasLayer
class_name PlayerHUD

@onready var pause_menu : UIMenu = $PauseMenu
@onready var vehicle_menu : UIMenu = $VehicleMenu

@onready var fps_label = $FPSLabel
@onready var health_lable = $HealthLabel

@onready var time_label = $TimeLabel

@onready var damage_display = $DamageDisplay
var damage_target_alpha = 0.0

var toast_scene : PackedScene = preload("res://src/UI/toast/toast.tscn")

func _ready() -> void:
	GV.set_HUD_reference(self)
	damage_display.modulate.a = damage_target_alpha

func _process(delta: float) -> void:
	#open_inventory()
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
	if(GV.player_node):
		var player_health_comp = GV.player_node.health_comp
		health_lable.text = "%.2f" % player_health_comp.health + " HP"
		
		damage_target_alpha = 1.0 - (player_health_comp.health / player_health_comp.max_health)
		damage_display.modulate.a = damage_target_alpha
		
	time_label.text = str(GV.save_data["play_time"] + (Time.get_ticks_msec() / 1000))

func create_toast(text : String):
	var new_toast : Toast = toast_scene.instantiate()
	add_child(new_toast)
	new_toast.display_text(text)
