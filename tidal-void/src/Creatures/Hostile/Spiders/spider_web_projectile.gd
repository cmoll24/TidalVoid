extends Orbiter
class_name WebProjectile

#the lifetime of the web in seconds before being destroyed
@export var lifetime : float = 4.5

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#decrement lifetime
	lifetime -= delta
	#destroy if lifetime reaches 0
	if(lifetime <= 0):
		die()
		
func _on_body_entered(body : Node2D):
	#cut the velocity if the body is not a spider
	if(body is DriftBody and body is not Charlotte):
		body.velocity = Vector2.ZERO
		
func die():
	queue_free()
