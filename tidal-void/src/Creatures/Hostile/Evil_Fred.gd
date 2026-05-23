extends Steven
class_name EvilFred

@export var bite_damage : float = 90
@export var bite_knockback : float = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#set the vision bitmask( use the | operator to add more)
	v_types = (1 << VisionSource.v_source_type.sPrey) | (1 << VisionSource.v_source_type.mPrey)
	
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
