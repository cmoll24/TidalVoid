extends PhysicsBody2D
class_name HeavyBody

@export var elasticity : float = 0.8;

var velocity : Vector2 = Vector2.ZERO

var last_pos : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_pos = global_position

func _physics_process(delta: float) -> void:
	velocity = (global_position - last_pos)/delta
	last_pos = global_position
