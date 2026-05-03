extends Creature
class_name Leaper

@onready var jump_timer = $JumpTimer

@export var surface_speed : float = 100.0

var target_asteroid : GravitySource

var walking_on_ground : bool = false

var jump_attemps : int =  0

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

func creature_movement(_delta):
	if b_is_grounded and jump_attemps > 0:
		set_airborne()
		walking_on_ground = false
		velocity = get_jump_vector()
		jump_attemps -= 1
	
	elif b_is_grounded and !walking_on_ground:
		velocity = Vector2.ZERO
		walking_on_ground = true

	elif b_is_grounded and walking_on_ground:
		ground_movement(_delta)

func ground_movement(_delta):
	if not target_asteroid:
		pick_next_asteroid()
	
	#Exit Condition
	if not b_is_grounded:
		walking_on_ground = false
	#if(velocity.dot(grounded_normal) < -1):
	#	print("exit")
	#	walking_on_ground = false
	#	grounded_buffer -= 1

	if jump_timer.is_stopped():
		var direction : Vector2 = (target_asteroid.global_position - global_position).normalized()
		
		var tangent = Vector2(-grounded_normal.y, grounded_normal.x)
		
		var speed = surface_speed * direction.dot(tangent)
		
		velocity = tangent * speed
		
		if speed < 1:
			jump_timer.start()

func get_jump_vector() -> Vector2:
	if not target_asteroid:
		return Vector2.ZERO
	
	var direction : Vector2 = (target_asteroid.global_position - global_position).normalized()
	
	var power : float = 1.2 * escape_speed(dominant_body, global_position)
	
	return direction * power

func _on_jump_timer_timeout() -> void:
	jump_attemps = 2

func on_collide_with_bubble(bubble : Bubble) -> void:
	#velocity = Vector2.ZERO
	pass
