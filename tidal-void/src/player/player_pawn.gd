extends DriftBody
class_name PlayerPawn

@onready var thrust_particles = $ThrustParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
