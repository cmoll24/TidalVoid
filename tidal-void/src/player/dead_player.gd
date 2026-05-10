extends PlayerPawn
class_name DeadPlayer

@onready var DeathParticles : CPUParticles2D = $DeathParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	thrust_power = 0
	
func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	thrust_direction = Vector2.ZERO
	
func start_possess(player_controller : PlayerController, previous_pawn_velocity : Vector2) -> void:
	super.start_possess(player_controller, previous_pawn_velocity)
	#GV.player_reference(self)
	velocity = previous_pawn_velocity
	DeathParticles.emitting = true
	
func die():
	# do nothing on death
	pass
