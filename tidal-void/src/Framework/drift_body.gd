extends PhysicsBody2D
class_name DriftBody

@onready var gravity_source = $GravitySource

@onready var collision_shape : CollisionShape2D = $CollisionShape2D

@onready var shape_cast : ShapeCast2D = $ShapeCast2D

## The mass of the body,s only affects collision with other drift bodies
@export var mass : float = 1

## the linear velocity of the body
@export var velocity : Vector2 = Vector2.ZERO

## total enumerated gravity force
var gravity_force : Vector2 = Vector2.ZERO

## total enumerated thruster force
var thruster_force : Vector2 = Vector2.ZERO

## total enumerated force
var total_force : Vector2 = Vector2.ZERO

################################################

##velocity used for prediction logic, enables things like predicting the player's jump
@export var prediction_velocity : Vector2 = Vector2.ZERO

##sets prediction velocity to the real velocity
@export var b_prediction_velo_is_real : bool = true;

###############################################

var grounded_body : GravitySource

var grounded_shape : CollisionShape2D

var grounded_normal: Vector2 = Vector2.ZERO

var grounded_buffer : int = 0


var b_is_grounded: bool = false

## the coefficient of static friction(applies when velocity is low to none)
@export var static_friction_coefficient : float = 0.6;

## velocities below this threshold will be considered as 0 for static friction
const STATIC_FRICTION_THRESHOLD: float = 0.005


## the coeficient for kinetic friction
@export var kinetic_friction_coefficient : float = 0.4;

## The minimum dot product(normalized, negated)(1 is a level floor, 0 is a straight wall, -1 is a ceiling(assuming gravity is main acceleration))
## with the acceleration and a surface needed to consider it ground
## (note that this system is gravity agnostic, fling something hard enough against a wall, and it is ground)
@export var min_dot_for_ground: float = 0.5

const MIN_MOVE_DISTANCE: float = 0.001

## How much energy is conserved during collisions
@export var elasticity: float = 0.8

#################################################################

@export var thrust_power : float = 50.0
var thrust_multiplier : float = 1.0
@export var max_velocity : float = 400.0

@export var start_in_orbit : bool = false

## normally colision does an extra safety check at the end to absolutely prevent clipping
## however, since this check is run through the engine and not manual, it can mess
## up physics, especially if the object is meant to be unstoppable or very heavy
@export var b_is_safe_collision : bool = true;

var thrust_direction : Vector2 = Vector2.ZERO

##########################################################


var game_manager : GameManager
var dominant_body : GravitySource = null


func _ready() -> void:
	game_manager = get_tree().get_first_node_in_group("game_managers")
	if(start_in_orbit):
		call_deferred("orbit_dominant_body");
	shape_cast.shape = collision_shape.shape

func orbit_dominant_body() -> void:
	velocity = orbital_velocity(dominant_body, global_position)

func _physics_process(_delta: float) -> void:
	update_dominant_body()

	#Apply the accerlation
	apply_acceleration();

	#Apply the velocity
	apply_velocity();
	
	if (grounded_buffer > 0):
		grounded_buffer -= 1; #what the hell, I can't even do -- in gdscripts
	else:
		#Call Set Airborne so that child classes can detect the event
		set_airborne();
	
	if(b_prediction_velo_is_real):
		prediction_velocity = velocity
	
	

##Calculate the changes to velocity as a result of gravity and thrusters
func  apply_acceleration() -> void:
	
	gravity_force = Vector2.ZERO
	
	for body in game_manager.gravity_sources:
		if(body == gravity_source):
			continue
		gravity_force += body.get_gravity_pull(global_position)
	
	var new_vel  = velocity + (gravity_force * get_physics_process_delta_time())
	
	if thrust_direction != Vector2.ZERO:
		thruster_force = thrust_direction * thrust_power * thrust_multiplier
		new_vel +=  thruster_force * get_physics_process_delta_time()
	else:
		thruster_force = Vector2.ZERO
		
	total_force = thruster_force + gravity_force
	velocity = new_vel.limit_length(max_velocity)

##Calculate the changes to velocity as a result of gravity and thrusters
func  apply_velocity() -> void:
	#from here the code is based directly on Physics_Pawn.gd, so it might look odd
	
	#Initial movment amount
	var moveDelta : Vector2 = velocity * get_physics_process_delta_time();
	#Skip tiny movements to optimize performance and prevent weird behavior from small amounts of residual velocity
	if(true || abs(max(moveDelta.x,moveDelta.y)) > MIN_MOVE_DISTANCE): #temporarily disabled the MinMoveDist
		#var InitialVelocity : Vector2 = velocity;
		
		#Trace what hits would happen with the current course of movement and save the initial hits
		shape_cast.target_position = moveDelta;
		shape_cast.force_shapecast_update()
		#Go through each hit
		for i in range(shape_cast.get_collision_count()):
			#Apply a simulated normal force
			var hitNormal : Vector2 = shape_cast.get_collision_normal(i)

			var dot : float = hitNormal.dot(velocity)

			if (dot < 0):
				#We have contact
				#Save the old velocity
				#var oldVelocity : Vector2 = velocity; #not currently needed
				#Simulate the base velocity change from the collision
				var velocityAdjustment : Vector2 = hitNormal * dot;
				#See if we can get information about the mass of what we are hitting
				#if we collided with another DriftBody, notify it and add impulse to simulate a special pawn collision
				if (shape_cast.get_collider(i) is DriftBody):
					var other_body : DriftBody = shape_cast.get_collider(i)
					other_body.on_collide_with_other_drift_body(self);
					var total_mass = mass + other_body.mass;
					var avg_elasticity = lerp(elasticity,other_body.elasticity,0.5)
					other_body.velocity += velocityAdjustment * mass/total_mass * avg_elasticity;
					velocity -= velocityAdjustment * other_body.mass/total_mass * avg_elasticity;
					on_collide_with_other_drift_body(other_body)
				else:
					#simply treat it as having infinite mass if it is not a drift body
					velocity -= velocityAdjustment;
						
				#Get the normal force
				var NormalForce : Vector2 = hitNormal * hitNormal.dot(total_force);
				
				#save the tangent to the normal force(direction doesn't matter as the dots will redirect it)
				var hitNormalPerp : Vector2 = Vector2(hitNormal.y,-hitNormal.x)
				
				#Apply friction
					#decide which coefficient of friction to use
				var friction_coefficient : float = kinetic_friction_coefficient
				if(velocity.length() < STATIC_FRICTION_THRESHOLD):
					friction_coefficient = static_friction_coefficient
				
					#perform the application
				var FrictionForce : float = (Vector2(NormalForce.y,-NormalForce.x) * friction_coefficient).length();
				var fricDot : float = hitNormalPerp.dot(velocity.normalized());
				velocity -= hitNormalPerp * fricDot * FrictionForce * get_physics_process_delta_time();	
		#Check for grounding if we are touching a compatible class
				if shape_cast.get_collider(i) is GravitySource:
					var NormAccel : Vector2 = total_force.normalized();
					#check that we are accelerating into it
					if(-NormAccel.dot(hitNormal) > min_dot_for_ground):
						#set it as ground
						set_ground(hitNormal,shape_cast.get_collider(i))
		#Cap velocity
		velocity.limit_length(max_velocity)
		#Update MoveDelta
		moveDelta = velocity * get_physics_process_delta_time();
	
	#Apply MoveDelta
	if(b_is_safe_collision):
		move_and_collide(moveDelta)
	else:
		global_position += moveDelta
	
		
func set_ground(normal : Vector2,body : Node2D) -> void:
	grounded_normal = normal;
	# We have 3 ticks of time away from being grounded before we lose the status
	grounded_buffer = 3;
	b_is_grounded = true;
	grounded_body = body;
	grounded_shape = grounded_body.shape
	
	# Ideally subclasses do some sort of other logic like rotating the model or something
	
func set_airborne() -> void:
	b_is_grounded = false;

func set_thurst(direction : Vector2, multiplier : float = 1.0) -> void:
	thrust_multiplier = multiplier
	
	if direction.length() > 0.1:
		thrust_direction = direction.normalized()
	else:
		thrust_direction = Vector2.ZERO

func update_dominant_body() -> void:
	#the domiannt body is the grav source with the strongest pull
	var strongest_pull = 0.0
	dominant_body = null
	for body in game_manager.gravity_sources:
		if(body == gravity_source):
			continue
		var pull = body.get_gravity_pull(global_position).length()
		if pull > strongest_pull:
			strongest_pull = pull
			dominant_body = body

func add_impulse(Impulse : Vector2) -> void:
	velocity += Impulse / mass;

@warning_ignore("unused_parameter")
func on_collide_with_other_drift_body(other : DriftBody) -> void:
	pass
	#For subclasses

func orbital_velocity(source : GravitySource, pos : Vector2) -> Vector2:
	if not source:
		return Vector2.ZERO
	
	var to_source = source.global_position - pos
	var distance = to_source.length()
	var speed = sqrt((source.mass * source.MASS_SCALE) / distance)
	return to_source.normalized().rotated(PI / 2.0) * speed	
	
	
