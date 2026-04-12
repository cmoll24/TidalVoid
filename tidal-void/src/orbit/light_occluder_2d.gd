@tool
extends LightOccluder2D # Or CollisionPolygon2D

#Quick AI generated tool so I don't
#need to manually input 32 vertices

@export var radius: float = 50.0:
	set(v):
		radius = v
		_update_circle()

@export var sides: int = 64:
	set(v):
		sides = v
		_update_circle()

func _update_circle():
	var points = PackedVector2Array()
	for i in range(sides):
		var angle = deg_to_rad(i * 360.0 / sides)
		points.push_back(Vector2(cos(angle), sin(angle)) * radius)
	
	# CRITICAL: You must re-assign the array to trigger the engine update
	if self is LightOccluder2D:
		var occluder_poly = OccluderPolygon2D.new()
		occluder_poly.polygon = points
		self.occluder = occluder_poly
