extends HuntingCreature
class_name StarRay

@onready var animation_player = $AnimationPlayer

@export var bite_damage : float = 150
@export var bite_knockback : float = 30

var target_attack_speed = 300.0

func _ready() -> void:
	super._ready()
	
	b_rotation_to_gravity = false
	#set the vision bitmask( use the | operator to add more)
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)


#NEW UNIQUE CREATURE MOVEMENT
func creature_movement(delta):
	# cannot be stunned and doesn't care about dominant body
	#eventually it should back off when entering a gravity field
	
	if (primary_v_source):
		var prey_node = primary_v_source.parent
		var prey_direction = global_position.direction_to(prey_node.global_position)
		target_rotation = prey_direction.angle() + (0.5  * PI)
		
		var prey_distance = global_position.distance_to(prey_node.global_position)
		
		if prey_distance < 400:
			animation_player.play("attack")
		else:
			animation_player.play("default")
			animation_player.speed_scale = clampf(5.0 - (prey_distance-200)/200, 1.0, 3.0)
		
		var target_point : Vector2 = prey_node.global_position
		var target_speed = max(velocity.length(), target_attack_speed + prey_node.get_velocity().length())
		
		if(prey_node.has_method("get_velocity")):
			var time_to_target = clampf(prey_distance / target_speed, 0.05, 2.0)
			target_point += prey_node.get_velocity() * time_to_target
			
		var target_direction = global_position.direction_to(target_point)
		var desired_velocity = target_direction * target_speed
		
		var thrust_dir = (desired_velocity - velocity).normalized()
		
		set_thrust(thrust_dir)
	else:
		animation_player.play("default")
		animation_player.speed_scale = 0.5
		
		#when the player is not visible, set the thrust to counteract some of the velocity
		
		#do nothing if in orbit
		
		if(abs(gravity_force.x) + abs(gravity_force.y) < 1):
			set_thrust(-velocity.normalized())
		

#Do reverse gravity
func update_gravity_force() -> void:
	gravity_force = Vector2.ZERO
	var max_pull : float = 0
	
	for body in game_manager.gravity_sources:
		if(body == gravity_source):
			continue
		#get the gravity force
		var gravity : Vector2 = body.get_gravity_pull(global_position);
		gravity_force -= gravity*2;
		#also update dominant body(increases performance at the cost of neatness)
		var pull : float = gravity.length_squared()
		if(pull > 1 and pull > max_pull): #if pull is valid and the greatest
			dominant_body = body
			max_pull = pull


	
func on_collide_with_other_drift_body(other : DriftBody) -> void:
	super.on_collide_with_other_drift_body(other);
	
	if b_in_hibernation: #Cannot attack while stunned
		return
	
	var vs : VisionSource = other.get_node_or_null("VisionSource")
	if(vs && (1 << vs.v_type) & v_types):
		if(vs == primary_v_source):
			primary_v_source = null;
		if(other):
			#deal knockback and physical damage if a health component exists
			var hc : HealthComponent = other.get_node_or_null('HealthComponent')
			if(hc):
				#physical damage
				hc.take_damage(bite_damage,HealthComponent.e_dmg_types.physical,self,self)
				#knockback damage
				hc.take_damage(bite_knockback,HealthComponent.e_dmg_types.knockback,self,self)
