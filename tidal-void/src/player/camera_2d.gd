class_name ZoomCamera
extends Camera2D

@export var min_zoom : float = 0.1
@export var max_zoom : float = 2.0
@export var zoom_speed : float = 0.05
@export var zoom_smoothing : float = 0.1

var target_zoom : float = 1.0

func _ready() -> void:
	target_zoom = zoom.x

func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		target_zoom = clamp(target_zoom * (1.0 + zoom_speed), min_zoom, max_zoom)
	elif event.is_action("zoom_out"):
		target_zoom = clamp(target_zoom / (1.0 + zoom_speed), min_zoom, max_zoom)

func _process(delta: float) -> void:
	#framerate in-depedent lerp: Mathf.Lerp(a, b, 1 - Mathf.Exp(-lambda * dt)) from https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 1.0 - exp(-zoom_smoothing * delta * 60.0))
