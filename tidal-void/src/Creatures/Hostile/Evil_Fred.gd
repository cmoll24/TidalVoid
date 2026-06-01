extends Steven
class_name EvilFred

@export var bite_damage : float = 90
@export var bite_knockback : float = 20

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#set the vision bitmask( use the | operator to add more)
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)
	
	
func _physics_process(delta: float) -> void:
	if(primary_v_source):
		#custom rotation if we have a primary v source
		b_rotation_to_gravity = false
		
		target_rotation = (primary_v_source.parent.global_position - global_position).angle() - (0.8*PI)
	else:
		b_rotation_to_gravity = true
	
	#call super after disabled or enabling rotation
	super._physics_process(delta);
	
func on_collide_with_other_drift_body(other : DriftBody) -> void:
	super.on_collide_with_other_drift_body(other);
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

func lunge(dist : float):
	super.lunge(dist);
	#set the sprite to open the mouth
	sprite.frame = 1
	#close the mouth later
	get_tree().create_timer(lunge_cldwn_time - 0.5).timeout.connect(set_sprite_closed)	


func set_sprite_closed():
	sprite.frame = 0
