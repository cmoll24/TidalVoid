extends DriftBody
class_name PlayerPawn

@onready var thrust_particles = $ThrustParticles

#the direction of the playerPawn to the mouse
var mouse_direction : Vector2

var controller : PlayerController

var last_velocity : Vector2 = Vector2.ZERO

var smoothed_delta_velocity : float = 0

### changes the rate at which the delta velocity is smoothed for camera effects, higher -> faster smoothing
@export var delta_velocity_smooth_factor : float = 2

signal update_traj_color(new_color : Color)

var INVERSE_PHYSICS_DELTA : float = 60

@export var death_pawn_path : String = "res://src/player/dead_player.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
###called when the use input is detected, override this function if you want something to happen
func action_use(pressed : bool) -> void:
	pass

###called when the propulsion key is pressed
func propulsion_ability():
	pass
	
func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	var delta_velocity = (velocity - last_velocity).length()*INVERSE_PHYSICS_DELTA
	smoothed_delta_velocity = lerp(smoothed_delta_velocity,delta_velocity,_delta*delta_velocity_smooth_factor)
	last_velocity = velocity
	
### called when the controller takes possession of this pawn
func start_possess(player_controller : PlayerController, previous_pawn_velocity : Vector2) -> void:
	controller = player_controller
	
	
### called when the controller stops taking possession of this pawn	
func stop_possess() -> void:
	#you can tell if you are possessed or not by checking the controller
	controller = null
	set_thrust(Vector2.ZERO)
	
func die() -> void:
	#on death
	var player_scene  = load(death_pawn_path)
	var player : PlayerPawn = player_scene.instantiate()
	get_tree().get_root().add_child(player)
	player.global_position = global_position
	#possess the player
	call_deferred('finish_death', player)
	collision_mask = 0
	shape_cast.collision_mask = 0
	
func finish_death(new_player : PlayerPawn) -> void:
	controller.possess_pawn(new_player,velocity)
	queue_free()
	
