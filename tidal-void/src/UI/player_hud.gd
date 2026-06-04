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
		health_lable.text = "%.2f" % GV.player_node.health_comp.health + " HP"
	time_label.text = str(GV.save_data["play_time"] + (Time.get_ticks_msec() / 1000))
	
	if damage_display.modulate.a > damage_target_alpha:
		damage_display.modulate.a -= 0.5 * delta

func create_toast(text : String):
	var new_toast : Toast = toast_scene.instantiate()
	add_child(new_toast)
	new_toast.display_text(text)

func damage_spike(current_hp : float, max_hp : float):
	damage_target_alpha = 1.0 - (current_hp / max_hp)
	damage_display.modulate.a = 1.0

func reset_damage_display(current_hp : float, max_hp : float):
	damage_target_alpha = 1.0 - (current_hp / max_hp)
	damage_display.modulate.a = damage_target_alpha
	
