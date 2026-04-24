extends PhysicsBody2D
class_name Bubble

### the inner radius of the bubble, no collisions occur here
@export var inner_radius: float = 40;

### constant velocity to send back things that bounce on the bubble with
#@export var bounce_strength : float = 50;
#
#var velocity : Vector2 = Vector2.ZERO
#
#var last_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#last_pos = global_position
	#
#func _physics_process(delta: float) -> void:
	#velocity = (global_position - last_pos)/delta
	#last_pos = global_position
	
### If the bubble refuses entry, returns a vector for the new velocity,
### makes no changes to velocity if the bubble shouldn't bounce(i.e. you are entering or inside it)
func can_penetrate_bubble(pos : Vector2, velo : Vector2) -> bool:
	var diff : Vector2 = global_position - pos
	return diff.dot(velo) < 0
