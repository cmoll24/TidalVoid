class_name Collectable
extends Orbiter

func _on_body_entered(body: Node2D) -> void:
	if body is DriftBody:
		queue_free()
