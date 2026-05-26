extends Orbiter
class_name WebProjectile

#the lifetime of the web in seconds before being destroyed
@export var lifetime : float = 4.5

#the amount of grab damage to do(should be a small number, 0<x<5)
@export var grab_damage : float = 2

var instigator : Node2D

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#decrement lifetime
	lifetime -= delta
	#destroy if lifetime reaches 0
	if(lifetime <= 0):
		die()
		
func _on_body_entered(body : Node2D):
	#hit non spider drift bodies
	if(body is DriftBody and body is not Charlotte):
		#stop their velocity
		body.velocity = Vector2.ZERO
		#deal grab damage, stunning creatures and ejecting the player from the creature carrier
		var hc : HealthComponent = body.get_node_or_null('HealthComponent')
		if(hc):
			#grab damage
			hc.take_damage(grab_damage,HealthComponent.e_dmg_types.grab,self,instigator)
		
func die():
	queue_free()
