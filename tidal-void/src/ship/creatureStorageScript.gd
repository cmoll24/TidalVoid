extends Bubble
class_name CreatureStorage

var move_speed : float = 50.0
var slow_radius : float = 100.0
var acceleration : float = 10.0

var target_position : Vector2 = Vector2.ZERO

var move_velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	target_position = position

func set_target_position(new_target : Vector2):
	target_position = new_target

func _physics_process(delta: float) -> void:
	var target_vec : Vector2 = target_position - position
	var distance : float = target_vec.length()
	
	if distance < 1.0:
		move_velocity = Vector2.ZERO
		position = target_position
		super._physics_process(delta)
	
	var direction : Vector2 = target_vec.normalized()
	
	var target_speed : float = move_speed
	if distance < slow_radius:
		#gradually reduce speed linearly as distnace approaches 0
		target_speed = move_speed * (distance / slow_radius)
	
	var target_velocity : Vector2 = direction * target_speed
	
	move_velocity = move_velocity.move_toward(target_velocity, acceleration * delta)
	
	global_position += move_velocity * delta
	
	#Determine velocity for creatures in bubble
	velocity = abs(move_velocity)
	
	
	
	
