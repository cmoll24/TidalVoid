extends PhysicsBody2D
class_name Bubble

### the inner radius of the bubble, things within this radius are not considered to be bouncing off the edges
@export var inner_radius: float = 40;

### the outer radius of the bubble, anything beyond this distance will be released(should be slightly larger than collision radius)
@export var outer_radius: float = 47;

### minimum velocity to bounce back with
@export var min_bounce_strength : float = 2;

### roughly(I didn't want to do math) the fraction of speed lost per a second in the bubble
@export var bubble_slow_fraction : float = 0.5

### fraction of velocity reflected back from the bubble when trying to escape
@export var bubble_reflect_fraction : float = 0.6

@onready var CollisionShape : CollisionShape2D = $BubbleCollider

@onready var Sprite : Sprite2D = $BubbleSprite

@export var b_bubble_enabled : bool = true

var velocity : Vector2 = Vector2.ZERO

var last_velocity : Vector2 = Vector2.ZERO

var last_pos : Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_pos = global_position
	if(!b_bubble_enabled):
		b_bubble_enabled = true;
		toggle_bubble()
	
func _physics_process(delta: float) -> void:
	velocity = (global_position - last_pos)/delta
	### smooth the velocity
	if(last_velocity != Vector2.ZERO):
		velocity = lerp(last_velocity,velocity,0.75)
	last_velocity = velocity
	last_pos = global_position
	
### If the bubble refuses entry, returns a vector for the new velocity,
### makes no changes to velocity if the bubble shouldn't bounce(i.e. you are entering or inside it)
func bounce_off_bubble(pos : Vector2, collision_radius : float, velo : Vector2) -> Vector2:
	var diff : Vector2 = global_position - pos
	var dist : float = diff.length()
	if(dist > outer_radius):
		### release the object if it is outside of the outer radiuss
		return velo
	#check that we are touching the edge of the bubble and not the middle
	if(dist  + collision_radius > inner_radius):
		#normalize diff
		diff = diff/dist;
		var dot : float = diff.dot(velo - velocity) # account for our own velocity
		#if the velocity is trying to escape the bubble, send it towards the center
		if(dot < 0):
			return velocity + (diff * max(abs(dot)*bubble_reflect_fraction,min_bounce_strength))
	else:
		##keep things trapped in the bubble
		return lerp(velo,velocity,bubble_slow_fraction*get_physics_process_delta_time())
	return velo
	
func toggle_bubble():
	b_bubble_enabled = !b_bubble_enabled
	if(!b_bubble_enabled):
		# bubbles just got turned off
		CollisionShape.disabled = true
		Sprite.visible = false
	else:
		# bubbles just got turned on
		CollisionShape.disabled = false
		Sprite.visible = true
		
