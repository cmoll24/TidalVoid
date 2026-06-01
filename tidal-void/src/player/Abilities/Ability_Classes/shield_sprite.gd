extends Sprite2D
class_name ShieldSprite

var lifetime : float

func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0:
		die()
	
func die():
	queue_free()
