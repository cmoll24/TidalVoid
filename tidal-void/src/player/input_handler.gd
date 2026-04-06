class_name InputHandler
extends Node

@export var player : DriftBody

func _process(delta: float) -> void:
	var thrust_direction = Vector2.ZERO
	
	### METHOD 1 - using four axis
	
	var horizontal_thrust = Input.get_axis("thrust_left", "thrust_right")
	var vertical_thrust = Input.get_axis("thrust_up", "thrust_down")
	
	thrust_direction = Vector2(horizontal_thrust, vertical_thrust)
	
	### METHOD 2 - using mouse direction
	
	if Input.is_action_pressed("thrust"):
	
		var mouse_position = get_viewport().get_mouse_position() - (get_viewport().get_visible_rect().size / 2)
		var player_screen_position = player.global_position - get_viewport().get_camera_2d().global_position
		
		print(mouse_position, player_screen_position)
		var mouse_direction = (mouse_position - player_screen_position).normalized()
		
		thrust_direction = mouse_direction
	
	player.set_thurst(thrust_direction)
