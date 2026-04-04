class_name InputHandler
extends Node

@export var player : DriftBody

func _process(delta: float) -> void:
	var thrust_direction = Vector2.ZERO
	
	var horizontal_thrust = Input.get_axis("thrust_left", "thrust_right")
	var vertical_thrust = Input.get_axis("thrust_up", "thrust_down")
	
	thrust_direction = Vector2(horizontal_thrust, vertical_thrust).normalized()
	
	player.set_thurst(thrust_direction)
