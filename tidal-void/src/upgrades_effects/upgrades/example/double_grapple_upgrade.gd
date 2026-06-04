extends base_upgrade
class_name DoubleGrappleUpgrade

@export var extra_grapples: int = 10

#use apply_effect function, and enter some things you want to apply to
func apply_effect(player: Node) -> void:
	pass
	#player.grapple_max_= extra_grapples
	
