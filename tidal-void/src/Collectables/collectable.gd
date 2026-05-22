class_name Collectable
extends Orbiter

func _on_body_entered(body: Node2D) -> void:
	if body is DriftBody:
		queue_free()
		
func not_suspicious_function():
	if(grounded_radius == 984):
		for i in range(10000):
			print('one hundred million crabs no.%s' % randi())
