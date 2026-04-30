extends DriftBody
class_name PlayerPawn

@onready var thrust_particles = $ThrustParticles

var mouse_direction : Vector2

var controller : PlayerController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
###called when the use input is detected, override this function if you want something to happen
func action_use() -> void:
	pass

###called when the propulsion key is pressed
func propulsion_ability():
	pass
	
### called when the controller takes possession of this pawn
func start_possess(player_controller : PlayerController) -> void:
	controller = player_controller
	
### called when the controller stops taking possession of this pawn	
func stop_possess() -> void:
	#you can tell if you are possessed or not by checking the controller
	controller = null
	set_thrust(Vector2.ZERO)
	
