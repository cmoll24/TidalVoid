class_name ZoomCamera
extends Camera2D

@export var min_zoom : float = 0.1
@export var max_zoom : float = 4.0
@export var zoom_speed : float = 0.05
@export var zoom_smoothing : float = 0.1

@export var map_zoom_threshold : float = 0.3

@export var charge_speed : float = .5
@export var return_speed : float = .1
@export var max_charge_zoom_in : float = -0.2   # zoom IN while holding

@export var jump_shake_strength : float = 2.0
@export var high_delta_velocity_mult : float = 0.01
### jump power must exceed this value for shake
@export var jump_power_shake_threshold = 100

var target_zoom : float = 1.0

var is_centered : bool = true
var camera_global_position : Vector2 = Vector2.ZERO
var drag_mouse_start_position : Vector2 = Vector2.ZERO

var jump_charge : float = 0.0
var jump_zoom_offset : float = 0.0
var jump_release_impulse : float = 0.0
var jumped = false

var player_controller : PlayerController
var player : PlayerPawn

func _ready() -> void:
	player_controller = get_parent()
	player = player_controller.player
	target_zoom = zoom.x

func _input(event: InputEvent) -> void:
	#Pinch Zoom
	if event is InputEventMagnifyGesture:
		var factor = event.factor
		target_zoom = clamp(
			target_zoom / factor,  
			min_zoom,
			max_zoom
		)
		
	if event.is_action("zoom_in"):
		target_zoom = clamp(target_zoom * (1.0 + zoom_speed), min_zoom, max_zoom)
	elif event.is_action("zoom_out"):
		target_zoom = clamp(target_zoom / (1.0 + zoom_speed), min_zoom, max_zoom)
	if event.is_action_pressed("camera_drag"):
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

	if not ignore_rotation:
		rotation = player.rotation
	else:
		rotation = 0.0
	
	if is_centered and zoom.x > map_zoom_threshold:
		apply_camera_shake(delta)
	
	if not is_centered:
		roaming_camera_process(delta)
	
	#framerate in-depedent lerp: Mathf.Lerp(a, b, 1 - Mathf.Exp(-lambda * dt)) from https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	var final_zoom_value = clamp(target_zoom * (1.0 + jump_zoom_offset), min_zoom, max_zoom)
	
	zoom = zoom.lerp(
		Vector2(final_zoom_value, final_zoom_value),
		1.0 - exp(-zoom_smoothing * delta * 60.0)
	)
	
func apply_camera_shake(delta):
	# camera shake at high velocities
	if player.smoothed_delta_velocity > 120:
		var shake = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * high_delta_velocity_mult * (93 - player.smoothed_delta_velocity)
		
		offset = shake
	else:
		offset = Vector2.ZERO
		
	# JUMP CHARGE EFFECT 
	if player is Player and player.is_charging_jump and Input.is_action_pressed("jump") and player.last_jump_power > jump_power_shake_threshold:
		if not player.b_is_grounded:
			return
		jumped = true
		jump_charge = clamp(jump_charge + delta * charge_speed, 0.0, 1.0)
		
		# zoom OUT while charging
		jump_zoom_offset = lerp(0.0, max_charge_zoom_in, jump_charge)
		#print(jump_zoom_offset)
		
		# small camera shake
		var shake = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * jump_shake_strength * jump_charge*(player.last_jump_power/player.max_jump_power)
		
		offset = shake
	else:
		jump_charge = 0
		if jump_zoom_offset < 0.0:
			#print(jump_zoom_offset)
			jump_zoom_offset += (delta * return_speed)
		else:
			jump_zoom_offset = 0.0

func roaming_camera_process(_delta : float) -> void:
	global_position = camera_global_position
	
	if Input.is_action_pressed("camera_drag"):
		var mouse_position = get_viewport().get_mouse_position() - (get_viewport().get_visible_rect().size / 2)
		camera_global_position = (drag_mouse_start_position - mouse_position / zoom)
