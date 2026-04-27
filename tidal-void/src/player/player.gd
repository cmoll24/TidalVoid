
extends PlayerPawn
class_name Player



#@export var jump_power : float = 200.0
@export var walk_speed : float = 620.0

@export var min_jump_power : float = 10.0
@export var max_jump_power : float = 300.0
@export var max_charge_time : float = 5.0  # seconds to reach full charge

var walking_on_ground : bool = false
var is_charging_jump : bool = false
var jump_charge_time : float = 0.0
var jump_escape_speed : float = 0.0

#This here is for player ability, the idea is to give the player
#a propulsion or after burner in case the player leaves orbit
#The max can be changed to whatever works but once the countdown hits 0,
#it won't be returned till after the player redocks with their ship
var propulsion_max : int = 3
var propulsions_left : int = 3
@export var propulsion_power : float = 300.0

var max_jump_angle : float = PI/2.5

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	GV.player_reference(self)
	super._ready()
	if self.is_in_group("player"):
		print("in player")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	player_movement(delta)

func player_movement(delta : float) -> void:
	if b_is_grounded && walking_on_ground:
		#Exit Condition
		if(velocity.dot(grounded_normal) < -1):
			walking_on_ground = false
			grounded_buffer -= 1
		
		#Handle Jumping
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			b_prediction_velo_is_real = false;
			jump_charge_time = 0.0
			jump_escape_speed = escape_speed(grounded_body, global_position)

		if is_charging_jump and Input.is_action_pressed("jump"):
			jump_charge_time += delta
			jump_charge_time = min(jump_charge_time, max_charge_time)
			prediction_velocity = get_jump_vector().limit_length(max_velocity);

		elif is_charging_jump: #no longer detects if the input was just released, this is so tabbing out can't trap you in jumping
			perform_jump()
			walking_on_ground = false
			b_prediction_velo_is_real = true;
		#Handle walking on ground
		
		#ignore collision with static geometry
		ignore_layer = 1
		#circle implementation
		if(grounded_shape.shape is CircleShape2D):
			var player_loc : Vector2 = global_position - grounded_body.global_position
			var player_loc_len : float = grounded_body.shape.shape.radius + collision_shape.shape.radius - 1
			var player_angle : float = player_loc.angle()
			var new_pos : Vector2
			var horizontal_mov = Input.get_axis("thrust_left", "thrust_right")
			if Input.is_action_pressed("thrust") or Input.is_action_pressed("controller_thrust"):
				#move when thrust is held, mouse version
				#var mouse_loc : Vector2 = get_global_mouse_position()- grounded_body.global_position
				var mouse_angle : float = mouse_direction.angle()
				var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
				var final_angle : float = rotate_toward(player_angle,mouse_angle,rot_speed)
				new_pos = (Vector2.from_angle(final_angle)*
				player_loc_len)+ grounded_body.global_position
			elif horizontal_mov != 0:
				#wasd, arrow keys version
				horizontal_mov = 1 if horizontal_mov > 0 else -1 #normalizes it
				var rot_speed = (walk_speed/(2*PI*player_loc_len)) * delta
				var final_angle : float = rotate_toward(player_angle,
				player_angle + (rot_speed*horizontal_mov),rot_speed)
				new_pos = (Vector2.from_angle(final_angle)*
				player_loc_len)+ grounded_body.global_position
			else:
				new_pos = (Vector2.from_angle(player_angle)*
				player_loc_len)+ grounded_body.global_position
			global_position = new_pos
			
			
		else:
			printerr("Walking on ground only supports circle shapes currently, invalid shape used")
	else:
		b_prediction_velo_is_real = true;
		if(b_is_grounded && !walking_on_ground):
			if(Input.is_action_pressed("grab")) or \
			  (velocity.length() < 1):
				is_charging_jump = false
				walking_on_ground = true
		ignore_layer = 0;
	
			
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	if(!(b_is_grounded && walking_on_ground)):
		#Thruster behavior when off of the ground
		super.set_thrust(direction, multiplier)
		if direction != Vector2.ZERO:
			thrust_particles.start_thrust(direction, velocity, thrust_power)
		else:
			thrust_particles.stop_thrust()
	else:
		thrust_particles.stop_thrust()
		

func get_jump_vector() -> Vector2:
	var charge_ratio = jump_charge_time / max_charge_time
	var curved_ratio = pow(charge_ratio, 0.5) #I like the feel of this better
	var max_jump = min(1.1 * jump_escape_speed, max_jump_power)
	var power =  lerp(min_jump_power, max_jump, curved_ratio)
	
	var up_direction = grounded_normal.normalized()
	
	if mouse_direction == Vector2.ZERO:
		return power * up_direction
	
	var angle_to_thrust = up_direction.angle_to(mouse_direction)
	
	if abs(angle_to_thrust) > max_jump_angle * 1.2:
	#	#instead of clamping the thrust angle, allow the player to cancel jumps by angling it at the planet
		return Vector2.ZERO
	elif abs(angle_to_thrust) > max_jump_angle:
		angle_to_thrust = clampf(angle_to_thrust, -max_jump_angle, max_jump_angle)
	
	return power * up_direction.rotated(angle_to_thrust)


func perform_jump():
	if not b_is_grounded:
		return
	
	var jump_vector = get_jump_vector()
	
	if(jump_vector == Vector2.ZERO):
		return
	velocity += jump_vector

	jump_charge_time = 0.0

func propulsion_ability():
	if propulsions_left > 0:
		propulsions_left -= 1
		velocity += (propulsion_power * mouse_direction)
		
func reset_abilities():
	propulsions_left = propulsion_max
