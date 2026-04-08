class_name InputHandler
extends Node

@export var player : Player

var reverse_thrust = false

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
		
		var mouse_direction = (mouse_position - player_screen_position).normalized()
		
		thrust_direction = mouse_direction
	
	var thrust_multiplier = 1.0
	if Input.is_action_pressed("boost"):
		thrust_multiplier = 10.0
	
	#This is very temporary: it's just a debug to check if this works
	if Input.is_action_just_pressed("jump"):
		player.jump()
	
	if reverse_thrust:
		player.set_thurst(thrust_direction.rotated(PI), thrust_multiplier)
	else:
		player.set_thurst(thrust_direction, thrust_multiplier)
