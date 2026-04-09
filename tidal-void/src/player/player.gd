
extends DriftBody
class_name Player

@onready var gravity_label = $GravityLabel

@onready var thrust_particles = $ThrustParticles

#@export var jump_power : float = 200.0
@export var walk_speed : float = 100.0

@export var min_jump_power : float = 50.0
@export var max_jump_power : float = 600.0
@export var max_charge_time : float = 3.0  # seconds to reach full charge

var is_charging_jump : bool = false
var jump_charge_time : float = 0.0

#var surface_friction_coef : float = 0.001

func _ready() -> void:
	super._ready()
	
	thrust_particles.emitting = false

func start_thrust_particles(direction):
	#the particles must have speed scale of 1.0 for this to work
	thrust_particles.speed_scale = 1.0
	
	var exhaust_direction = -direction
	var spread = 0.1 * randf_range(-1, 1)
	
	var exhaust_speed : float = thrust_power * 10
	
	var total_velocity = velocity + exhaust_speed * exhaust_direction.rotated(spread)
	
	var particle_speed = total_velocity.length()
	var particle_direction = total_velocity.normalized()
	
	# must use .rotated(-rotation) so that the direction does not depend on player rotation
	thrust_particles.direction = particle_direction.rotated(-global_rotation)
	thrust_particles.initial_velocity_min = particle_speed * 0.9
	thrust_particles.initial_velocity_max = particle_speed * 1.1
	
	thrust_particles.emitting = true

func _physics_process(delta: float) -> void:
	if b_is_grounded:
		if Input.is_action_just_pressed("jump"):
			is_charging_jump = true
			b_prediction_velo_is_real = false;
			jump_charge_time = 0.0

		if is_charging_jump and Input.is_action_pressed("jump"):
			jump_charge_time += delta
			jump_charge_time = min(jump_charge_time, max_charge_time)
			var charge_ratio = jump_charge_time / max_charge_time
			var power : float= lerp(min_jump_power, max_jump_power, charge_ratio)
			prediction_velocity = velocity + (power * grounded_normal);

		elif is_charging_jump: #no longer detects if the input was just released, this is so tabbing out can't trap you in jumping
			perform_jump()
			b_prediction_velo_is_real = true;
			
func set_thurst(direction : Vector2, multiplier : float = 1.0) -> void:
	super.set_thurst(direction, multiplier)
	
	if direction != Vector2.ZERO and not b_is_grounded:
		start_thrust_particles(direction)
	else:
		thrust_particles.emitting = false

#func jump():
#	if not is_grounded:
#		return
#	apply_central_impulse(jump_power * surface_normal)

func perform_jump():
	if not b_is_grounded:
		return

	is_charging_jump = false

	var charge_ratio = jump_charge_time / max_charge_time

	var final_power = lerp(min_jump_power, max_jump_power, charge_ratio)

	velocity += final_power * grounded_normal

	jump_charge_time = 0.0

func handle_ground_movement(state: PhysicsDirectBodyState2D):
	if grounded_body == null:
		return

	var up_dir = grounded_normal.normalized()

	rotation = up_dir.angle() + PI/2

	state.angular_velocity = 0

	var tangent = Vector2(-up_dir.y, up_dir.x)

	var input_dir = 0
	if Input.is_action_pressed("thrust_left"):
		input_dir -= 1
	if Input.is_action_pressed("thrust_right"):
		input_dir += 1

	var target_velocity = tangent * input_dir * walk_speed

	var radial_velocity = up_dir * state.linear_velocity.dot(up_dir)
	state.linear_velocity = radial_velocity + target_velocity
