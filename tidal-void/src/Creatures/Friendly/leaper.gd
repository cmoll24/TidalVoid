extends Creature

@onready var jump_timer = $JumpTimer

@export var surface_speed : float = 300.0

var target_asteroid : GravitySource

var walking_on_ground : bool = false

func pick_next_asteroid():
	
	var min_distance_sq = INF
	var closest_asteroid = null
	
	for asteroid in game_manager.gravity_sources:
		if asteroid == dominant_body:
			continue
		
		var distance_sq = global_position.distance_squared_to(asteroid.global_position)
		if distance_sq < min_distance_sq:
			closest_asteroid = asteroid
			min_distance_sq = distance_sq
	
	target_asteroid = closest_asteroid

func update_dominant_body() -> void:
	super.update_dominant_body()
	
	if target_asteroid == dominant_body:
		pick_next_asteroid()

func creature_movement(delta):
	if(b_is_grounded and !walking_on_ground):
		print("walking on ground")
		velocity = Vector2.ZERO
		walking_on_ground = true

	elif b_is_grounded and walking_on_ground:
		ground_movement(delta)

func ground_movement(delta):
	if not target_asteroid:
		pick_next_asteroid()
	
	#Exit Condition
	if(velocity.dot(grounded_normal) < -1):
		print("exit")
		walking_on_ground = false
		grounded_buffer -= 1

	if jump_timer.is_stopped():
		if(grounded_shape.shape is CircleShape2D):
			var direction : Vector2 = (target_asteroid.global_position - global_position).normalized()
			
			var creature_loc : Vector2 = global_position - grounded_body.global_position
			var creature_loc_len : float = grounded_body.shape.shape.radius + collision_shape.shape.radius - 1
			var creature_angle : float = creature_loc.angle()
			
			var target_angle : float = direction.angle()
			var rot_speed = (surface_speed/(2*PI*creature_loc_len)) * delta
			var final_angle : float = rotate_toward(creature_angle,target_angle,rot_speed)
			global_position = (Vector2.from_angle(final_angle)*creature_loc_len)+ grounded_body.global_position
	
			if final_angle == target_angle:
				jump_timer.start()

func get_jump_vector() -> Vector2:
	if not target_asteroid:
		return Vector2.ZERO
	
	var direction : Vector2 = (target_asteroid.global_position - global_position).normalized()
	
	var power : float = 1.2 * escape_speed(dominant_body, global_position)
	
	return direction * power

func _on_jump_timer_timeout() -> void:
	print("jump from ", dominant_body)
	set_airborne()
	walking_on_ground = false
	velocity = get_jump_vector()
