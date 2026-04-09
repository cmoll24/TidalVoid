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

var grounded_normal: Vector2 = Vector2.ZERO

var grounded_buffer : int = 0


var b_is_grounded: bool = false

## Velocities below this value times friction will encounter static friction, stopping them, this isn't a very realistic way to go about it, but it does the best job
@export var min_stat_fric_velo: float = 0.2

## the coeficient for kinetic friction
@export var kinetic_friction_coefficient : float = 0.4;

## The minimum dot product(normalized, negated)(1 is a level floor, 0 is a straight wall, -1 is a ceiling(assuming gravity is main acceleration))
## with the acceleration and a surface needed to consider it ground
## (note that this system is gravity agnostic, fling something hard enough against a wall, and it is ground)
@export var min_dot_for_ground: float = 0.5

const MIN_MOVE_DISTANCE: float = 0.0

## How much energy is conserved during collisions
@export var elasticity: float = 0.8

#################################################################

@export var thrust_power : float = 50.0
var thrust_multiplier : float = 1.0
@export var max_velocity : float = 400.0

@export var start_in_orbit : bool = false

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
				var oldVelocity : Vector2 = velocity;
				#Simulate the base velocity change from the collision
				var velocityAdjustment : Vector2 = hitNormal * dot;
				velocity -= velocityAdjustment;
						
				#Apply the normal force (disabled for now unless we need it later)
				#Asssuming for now that the gravity force is the only one present
				var NormalForce : Vector2 = hitNormal * hitNormal.dot(total_force);
				#forces[1] -= NormalForce;
				var hitNormalPerp : Vector2 = Vector2(hitNormal.y,-hitNormal.x)
				#Apply friction
				if((velocity * hitNormalPerp).length() < min_stat_fric_velo):
					#Static friction
					var fricDot : float = hitNormalPerp.dot(velocity);
					velocity -= hitNormalPerp * fricDot;
				else:
					#Kinetic friction
					var FrictionForce : float = (Vector2(NormalForce.y,-NormalForce.x) * kinetic_friction_coefficient).length();
					var fricDot : float = hitNormalPerp.dot(velocity.normalized());
					velocity -= hitNormalPerp * fricDot * FrictionForce * get_physics_process_delta_time();
				#Check for grounding
				var NormAccel : Vector2 = total_force.normalized();
				if(-NormAccel.dot(hitNormal) > min_dot_for_ground):
					#let set ground handle the details
					set_ground(hitNormal,shape_cast.get_collider(i))
				#if we collided with another DriftBody, notify it and add impulse to simulate a special pawn collision
				if (shape_cast.get_collider(i).is_class("DriftBody")):
					var other_body : DriftBody = shape_cast.get_collider(i)
					if (other_body):
						other_body.on_collide_with_other_drift_body(self);
						other_body.add_impulse((oldVelocity - velocity) * mass * elasticity);
		#Update MoveDelta
		moveDelta = velocity * get_physics_process_delta_time();
		
	move_and_collide(moveDelta)
	
		
func set_ground(normal : Vector2,body : Node2D) -> void:
	grounded_normal = normal;
	# We have 3 ticks of time away from being grounded before we lose the status
	grounded_buffer = 3;
	b_is_grounded = true;
	if(body.is_class("GravitySource")):
		grounded_body = body;
	
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
	
	
