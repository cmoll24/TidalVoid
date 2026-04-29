extends PhysicsBody2D
class_name Bubble

### the inner radius of the bubble, no collisions occur here
@export var inner_radius: float = 40;

### minimum velocity to bounce back with
@export var min_bounce_strength : float = 1;

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
			return velocity + (diff * max(abs(dot),min_bounce_strength))
	return velo
