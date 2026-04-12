#This is an old script of mine ported from a Unity project, it might be a little weird in structure and naming as it is not native to Godot

# Not Usable in current state, full port incomplete.

#I am keeping it here for reference as it has a lot of code I can reuse

"""

class_name PhysicsPawn
extends node


##The mass of the pawn, due to the kinematic nature of the physics simulation, it cannot be set directly on the rigidbody
@export var mass : float = 1

##The velocity of the pawn, applied every fixed update
@export var velocity : Vector2;

## When the velocity is past the soft cap, it will have a harder time accelerating the closer it gets to the hard cap
@export var velo_soft_cap: float = 35

## The maximum velocity the pawn can attain
@export var velo_hard_cap: float = 50


## The forces being applied to the pawn
## General Convention:
## Index 0 is reserved for gravity
## Index 1 is reserved for the sum of normal forces
## Index 2 is reserved for environmental forces such as wind
## Index 3 is reserved for friction
## Use Indexes 4+ for external forces like thrusters
## These are stored assuming pure kinematic mass 1, apply all mass calculations separately
@export var forces: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO,Vector2.ZERO]

## The acceleration of the pawn, update its value to the sum of forces with the SumForces function
@export var acceleration: Vector2


## The minimum dot product(normalized, negated)(1 is a level floor, 0 is a straight wall, -1 is a ceiling(assuming gravity is main acceleration))
## with the acceleration and a surface needed to consider it ground
## (note that this system is gravity agnostic, fling something hard enough against a wall, and it is ground)
@export var min_dot_for_ground: float = 0.5

## How much energy is conserved during collisions
@export var elasticity: float = 0.8
## Scales kinetic friction
@export var friction_multiplier: float = 1

## Velocities below this value times friction will encounter static friction, stopping them, this isn't a very realistic way to go about it, but it does the best job
@export var min_stat_fric_velo: float = 0.2

var grounded_normal: Vector2

var b_is_grounded: bool

@export var ground_phys_mat: PhysicsMaterial

var _body: RigidBody2D

var _collision_mask : int
var _hit_buffer: Array # RaycastHit2D[]
var _hit_buffer_count: int = 0
const MIN_MOVE_DISTANCE: float = 0.001
var _grounded_buffer: int = 2

func _ready() -> void:
	body = $rigid_body
	contactFilter.useTriggers = false;
	contactFilter.SetLayerMask(Physics2D.GetLayerCollisionMask(gameObject.layer));
	contactFilter.useLayerMask = true;
	body.mass = mass;

func sum_forces() -> void:
	var acceleration = Vector2.ZERO;
	for i in range(forces.size()):
		acceleration += forces[i]

##Fixed update calls in sync with the physics
func _physics_process(_delta: float) -> void:
	bIsGrounded = false;

	#Apply the accerlation
	ApplyAcceleration();

	#Apply the velocity
	ApplyVelocity();
	if (!bIsGrounded):
		if (groundedBuffer > 0):
			groundedBuffer -= 1; #what the hell, I can't even do -- in gdscript
			bIsGrounded = true;
		else:
			#Redundantly call Set Airborne so that child classes can detect the event
			SetAirborne();


#Applies a specified velocity to the position(assumes fixed delta time
func ApplyVelocity() -> void:
	#First zero out the normal and friction forces
	forces[1] = Vector2.ZERO;

	SumForces();
	forces[3] = Vector2.ZERO;

	#Initial movment amount
	var moveDelta : Vector2 = velocity * 0.02;
	var moveDist : float = moveDelta.length();
	#Skip tiny movements to optimize performance and prevent weird behavior from small amounts of residual velocity
	if(moveDist > minMoveDistance):
		var InitialVelocity : Vector2 = velocity;
		#Trace what hits would happen with the current course of movement and save the initial hits to hitBuffer
		hitBufferCount = body.Cast(moveDelta, contactFilter, hitBuffer, moveDist);
		#Go through each hit
		for i in range(hitBufferCount):
			#Apply a simulated normal force
			var hitNormal : Vector2 = hitBuffer[i].normal;

			var dot : float = hitNormal.dot(velocity)

			if (dot < 0):
				#We have contact
				#Save the old velocity
				var oldVelocity : Vector2 = velocity;
				#Simulate the base velocity change from the collision
				var velocityAdjustment : Vector2 = hitNormal * dot;
				velocity -= velocityAdjustment;
				#Apply the normal force
				var NormalForce : Vector2 = hitNormal * hitNormal.dot(acceleration);
				forces[1] -= NormalForce;
				#Check if we have a physical material
				var physmat : PhysicsMaterial = hitBuffer[i].collider.sharedMaterial;
				if (physMat):
					#Apply friction
					if((velocity * hitNormal.Perpendicular1()).length() < minStatFricVelo* physMat.friction):
						#Static friction
						var fricDot : float = Vector2.Dot(hitNormal.Perpendicular1(), velocity);
						velocity -= hitNormal.Perpendicular1() * fricDot;
					else:
						#Kinetic friction
						var FrictionForce : float = (NormalForce.Perpendicular1() * physMat.friction).length();
						var fricDot : float = Vector2.Dot(hitNormal.Perpendicular1(), velocity.normalized);
						forces[3] -= hitNormal.Perpendicular1() * fricDot * FrictionForce * frictionMultiplier;
					#Calculate for an elastic collision if conditions allow
					if (physMat.bounciness > 0 &&
					velocityAdjustment.length() > acceleration.length() * 0.12 ): #it takes at least 6 frames of buildup to justify a bounce
						velocity -= velocityAdjustment * elasticity * physMat.bounciness;
				#Check for grounding
				var NormAccel : Vector2 = acceleration.normalized;
				if(-NormAccel.dot(hitNormal) > MinDotForGround):
					SetGround(hitNormal, hitBuffer[i].collider.sharedMaterial);
				#if we collided with another pawn, notify it and add impulse to simulate a special pawn collision
				if (hitBuffer[i].rigidbody):
					var OtherPawn : PhysicsPawn = hitBuffer[i].rigidbody.gameObject.GetComponent<PhysicsPawn>();
					if (OtherPawn):
						OtherPawn.OnCollideWithPawn(this);
						OtherPawn.ImpartMomentum((oldVelocity - velocity) * body.mass * elasticity);
		#Do absolute check to ensure that we have no clipping
		moveDelta = velocity * 0.02;
		moveDist = moveDelta.length();
		var deltaVelocity : Vector2 = velocity - InitialVelocity;

		hitBufferCount = body.Cast(moveDelta, contactFilter, hitBuffer, moveDist);
		for i in range(hit_buffer_count - 1, -1, -1):
			#We get the most offending point on our pawn to the normal and we check how far clipped past the hit point it is
			var FarthestPoint : Vector2 = body.ClosestPoint(body.position - hitBuffer[i].normal * 300)+ moveDelta; #300 is arbitrary, it just needs to a a point outside collision
			if (hitBuffer[i].collider.OverlapPoint(FarthestPoint)):
				moveDelta += hitBuffer[i].point - FarthestPoint;
		#Now that moveDelta is clamped so that it cannot defy collision, apply it
		body.position += (moveDelta);


func SetGround(Normal : Vector2, physMat : PhysicsMaterial) -> void:
	GroundedNormal = Normal;
	GroundPhysMat = physMat;
	groundedBuffer = 3;
	bIsGrounded = true;
	#Ideally subclasses do some sort of other logic like rotating the model or something

func SetAirborne() -> void:
	bIsGrounded = false;

#Applies all acceleration to velocity
func ApplyAcceleration() -> void:
	var veloMag : float = velocity.length();
	var OldVelo : Vector2 = velocity;
	#Apply acceleration
	SumForces();
	velocity += acceleration * 0.02;
  
	#Check for soft cap
	if (veloMag > veloSoftCap && veloMag < veloHardCap):
		#This goes between 0 and 100% of accleration removed as pawn goes from the soft to the hard cap
		var AccelReduction : float = (veloMag - veloSoftCap) / (veloHardCap - veloSoftCap);
		var normalizedVelo : Vector2 = velocity.normalized();
		if (abs(OldVelo.x) > abs(velocity.x)):
			#Reduce the effect of the acceleration
			velocity.x = lerp(velocity.x, OldVelo.x, AccelReduction * normalizedVelo.x);
		if (abs(OldVelo.y) > abs(velocity.y)):
			#Reduce the effect of the acceleration
			velocity.y = lerp(velocity.y, OldVelo.y, AccelReduction * normalizedVelo.y);
	#Ensure that velocity cannot grow over the hard cap
	if (veloMag > veloHardCap):
		velocity = velocity.normalized();
		velocity *= veloHardCap;
		
func ImpartMomentum(Impulse : Vector2) -> void:
	velocity += Impulse / body.mass;

func OnCollideWithPawn(other : PhysicsPawn) -> void:
	pass
	#For subclasses
"""
