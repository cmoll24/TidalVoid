class_name PlayerController
extends Node

@export var player : PlayerPawn

@export var predictor : TrajectoryPredictor

@onready var camera : ZoomCamera = $Camera2D

var reverse_thrust = false

var controller_mode = false

func _ready() -> void:
	if(player):
		predictor.player = player
		player.start_possess(self, Vector2.ZERO)

func _process(_delta: float) -> void:
	var thrust_direction = Vector2.ZERO
	
	### METHOD 1 - using four axis
	
	var horizontal_thrust = Input.get_axis("thrust_left", "thrust_right")
	var vertical_thrust = Input.get_axis("thrust_up", "thrust_down")
	
	thrust_direction = Vector2(horizontal_thrust, vertical_thrust)
	if not camera.ignore_rotation:
		thrust_direction = thrust_direction.rotated(player.rotation)
	
	### METHOD 2 - using mouse direction
	
	var mouse_world_position = camera.get_global_mouse_position()

	var mouse_direction = (mouse_world_position - player.global_position).normalized()
	player.mouse_direction = mouse_direction
	
	### METHOD 3 - using controller direction
	
	if controller_mode:
		var controller_horizontal = Input.get_axis("controller_left", "controller_right")
		var controller_vertical = Input.get_axis("controller_up", "controller_down")
		var controller_direction = Vector2(controller_horizontal, controller_vertical)
		
		if Input.is_action_pressed("controller_thrust"):
			thrust_direction = controller_direction
			
		player.mouse_direction = controller_direction

	if Input.is_action_pressed("thrust"):
		thrust_direction = mouse_direction
	
	var thrust_multiplier = 1.0
	if Input.is_action_pressed("boost"):
		thrust_multiplier = 10.0
	
	#if Input.is_action_just_pressed("jump"):
 	#	player.jump()
	
	if reverse_thrust:
		player.set_thrust(thrust_direction.rotated(PI), thrust_multiplier)
	else:
		player.set_thrust(thrust_direction, thrust_multiplier)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("propulsion"):
		player.propulsion_ability()
	elif event.is_action_pressed("Use"):
		player.action_use(true)
	elif event.is_action_released("Use"):
		player.action_use(false)
		
		
func possess_pawn(pawn : PlayerPawn, previous_pawn_velocity : Vector2):
	camera.player = pawn
	player.stop_possess();
	pawn.start_possess(self, previous_pawn_velocity);
	player = pawn;
	predictor.update_player(player)
