extends Steven
class_name HungryHarry

@export var worm_length : int = 512

#should be a multiple of worm_length
@export var line_point_num : int = 128

@export var worm_thickness : int = 64

#should be a multiple of worm_length
@export var body_collider_num : int = 8

@export var worm_burrow_distance : float = 160

@export var burrow_rotation_boost : float = 0.001

var body_collider_length : int = 64

var line_point_dist : int = 4

var last_pos : Vector2 = Vector2.ZERO

var b_in_planet : bool = false

@onready var line : Line2D = $Body

@onready var head : Sprite2D = $Head

@onready var tail : Sprite2D = $Tail

@onready var body_collision : StaticBody2D = $BodyCollision

var body_colliders : Array[CollisionShape2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#initialize last pos and line point dist and body collider length
	last_pos = global_position;
	line_point_dist = worm_length/line_point_num; # I had to silence all warnings for integer division, it was too annoying
	body_collider_length = worm_length/body_collider_num
	
	#since there is no position history, build the initial body as a straight downward line
	var points : PackedVector2Array = [];
	for i in line_point_num:
		points.append(global_position + Vector2(0,32+(i*line_point_dist)));
	line.points = points;
	
	#initialize colliders
	for i in range(body_collider_num):
		var collider : CollisionShape2D = CollisionShape2D.new()
		collider.shape = RectangleShape2D.new()
		collider.shape.size = Vector2(worm_thickness,body_collider_length)
		body_collision.add_child(collider)
		collider.position = Vector2(0,(i+0.5)*body_collider_length)
		
	#setup collision exceptions
	add_collision_exception_with(body_collision)
	shape_cast.add_exception(body_collision)
	
	v_exceptions.append(body_collision.get_rid())
	
	#vision
	
	#set the vision bitmask( use the | operator to add more)
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta);
	#check if we are inside a planet
	b_in_planet = dominant_body and dominant_body.global_position.distance_squared_to(global_position) < dominant_body.collision_radius**2
	if(v_exceptions.find(dominant_body.get_rid()) == -1):
		v_exceptions.append(dominant_body.get_rid())
	#update the line
	update_worm_line();
	
func apply_acceleration() -> void:
	var new_vel = velocity

	#only apply full gravity if we are not inside a planet
	if(!b_in_planet):
		update_gravity_force()
		new_vel += (gravity_force * get_physics_process_delta_time())
	else:
		#only apply thrust while in a planet
		
		update_thruster_force()
	
		new_vel +=  thruster_force * get_physics_process_delta_time()
		
	total_force = thruster_force + gravity_force
	velocity = new_vel.limit_length(max_velocity)
	
### every time we travel line_point_dist, add a new point and remove the last one
func update_worm_line() -> void:
	
	var diff : Vector2 = global_position - last_pos;
	var dist : float = diff.length();
	var dir : Vector2 = diff/dist;
	#update body position to follow the head
	line.position = diff;
	#update head position and rotation
	head.rotation = diff.angle()+PI/2;
	var end_diff : Vector2 = line.points[-1] - line.points[-2]
	while(dist >= line_point_dist): ##move the line in increments
		
		################################### updating line and colliders
		#update last pos to be exactly line_point dist aways
		last_pos += dir*line_point_dist;
		dist = last_pos.distance_to(global_position)
		
		# update the lines
		
		line.add_point(last_pos-dir*(worm_thickness*0.5),0);
		line.remove_point(line_point_num); #we have an extra point from the last line
		
		# update the colliders
		
		for i in range(body_collider_num):
			var collider : CollisionShape2D = body_collision.get_child(i)
			#index of the point in the body line where our collider should be at
			var point_index : int = int((i+0.5)*(body_collider_length/line_point_dist))
			collider.global_position = line.points[point_index]
			collider.global_rotation = (line.points[point_index] - line.points[point_index - 1]).angle()+PI/2
			
func update_behavior() -> void:
	#check for hibernation
	b_in_hibernation = time_since_last_vision > time_before_hibernate
	
func creature_movement(_delta):
	thrust_direction = Vector2.ZERO
	if(b_in_planet && stun_time <= 0):
		if(primary_v_source):
			#move straight for the source with direct velocity
			var diff : Vector2 = primary_v_source.parent.global_position - global_position
			if(velocity.angle_to(diff) > PI/2.5):
				velocity = Vector2.from_angle(rotate_toward(velocity.angle(),diff.angle(),burrow_rotation_boost))
				 
			set_thrust(diff,2)
		elif(dominant_body.global_position.distance_squared_to(global_position) > (dominant_body.collision_radius-(worm_burrow_distance))**2):
			#move to the center of the planet to hide
			set_thrust(dominant_body.global_position - global_position)
		else:
			set_thrust((dominant_body.global_position - global_position).rotated(90))
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	thrust_multiplier = multiplier
	
	if direction.length() > 0.1:
		thrust_direction = direction.normalized()
	else:
		thrust_direction = Vector2.ZERO
		
	
	
func on_collide_with_other_drift_body(other : DriftBody) -> void:
	super.on_collide_with_other_drift_body(other);
	var vs : VisionSource = other.get_node_or_null("VisionSource")
	if(vs && (1 << vs.v_type) & v_types):
		if(vs == primary_v_source):
			primary_v_source = null;
		other.die()
