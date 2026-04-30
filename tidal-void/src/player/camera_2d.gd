class_name ZoomCamera
extends Camera2D

@export var min_zoom : float = 0.1
@export var max_zoom : float = 4.0
@export var zoom_speed : float = 0.05
@export var zoom_smoothing : float = 0.1

var target_zoom : float = 1.0

var is_centered : bool = true
var camera_global_position : Vector2 = Vector2.ZERO
var drag_mouse_start_position : Vector2 = Vector2.ZERO

var player_controller : PlayerController

func _ready() -> void:
	player_controller = get_parent()
	target_zoom = zoom.x

func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		target_zoom = clamp(target_zoom * (1.0 + zoom_speed), min_zoom, max_zoom)
	elif event.is_action("zoom_out"):
		target_zoom = clamp(target_zoom / (1.0 + zoom_speed), min_zoom, max_zoom)
	elif event.is_action_pressed("camera_drag"):
		is_centered = false
		ignore_rotation = true
		var mouse_position = get_viewport().get_mouse_position() - (get_viewport().get_visible_rect().size / 2)
		camera_global_position = global_position
		drag_mouse_start_position = camera_global_position + mouse_position / zoom
	elif event.is_action_pressed("center_camera"):
		is_centered = true
		position = Vector2.ZERO
	elif event.is_action_pressed("camera_rotation_lock"):
		if ignore_rotation:
			ignore_rotation = false
			is_centered = true
			position = Vector2.ZERO
		else:
			ignore_rotation = true

func _process(delta: float) -> void:
	global_position = player_controller.player.global_position
	#framerate in-depedent lerp: Mathf.Lerp(a, b, 1 - Mathf.Exp(-lambda * dt)) from https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 1.0 - exp(-zoom_smoothing * delta * 60.0))
	
	if not ignore_rotation:
		rotation = player_controller.player.rotation
	else:
		rotation = 0.0
	
	if not is_centered:
		roaming_camera_process(delta)

func roaming_camera_process(_delta : float) -> void:
	global_position = camera_global_position
	
	if Input.is_action_pressed("camera_drag"):
		var mouse_position = get_viewport().get_mouse_position() - (get_viewport().get_visible_rect().size / 2)
		camera_global_position = (drag_mouse_start_position - mouse_position / zoom)
