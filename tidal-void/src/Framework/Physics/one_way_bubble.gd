extends PhysicsBody2D
class_name Bubble

### the inner radius of the bubble, no collisions occur here
@export var inner_radius: float = 40;

### minimum velocity to bounce back with
@export var min_bounce_strength : float = 0.5;

### the speed at which the velocity of drifbodies in the bubble is reduced per second
@export var bubble_slow_speed : float = 10

### fraction of velocity reflected back from the bubble when trying to escape
@export var bubble_reflect_fraction : float = 0.6

var velocity : Vector2 = Vector2.ZERO

var last_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_pos = global_position
	
func _physics_process(delta: float) -> void:
	velocity = (global_position - last_pos)/delta
	last_pos = global_position
	
### If the bubble refuses entry, returns a vector for the new velocity,
### makes no changes to velocity if the bubble shouldn't bounce(i.e. you are entering or inside it)
func bounce_off_bubble(pos : Vector2, collision_radius : float, velo : Vector2) -> Vector2:
	var diff : Vector2 = global_position - pos
	var dist : float = diff.length()
	#check that we are touching the edge of the bubble and not the middle
	if(dist  + collision_radius > inner_radius):
		#normalize diff
		diff = diff/dist;
		var dot : float = diff.dot(velo - velocity) # account for our own velocity
		#if the velocity is trying to escape the bubble, send it towards the center
		if(dot < 0):
			return velocity + ((diff * max(abs(dot),min_bounce_strength))*bubble_reflect_fraction)
	else:
		##keep things trapped in the bubble
		return velo.move_toward(velocity,bubble_slow_speed * get_physics_process_delta_time())
	return velo
