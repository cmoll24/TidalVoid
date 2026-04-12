extends GravitySource
class_name Planet

@onready var occluder : LightOccluder2D = $LightOccluder2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	occluder.scale.x = collision_radius*1.03
	occluder.scale.y = collision_radius*1.03
