extends PlayerPawn
class_name DeadPlayer

@onready var DeathParticles : CPUParticles2D = $DeathParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	thrust_power = 0
	#respawn after a second
	get_tree().create_timer(1).timeout.connect(respawn)
	
###TEMPORARY IMPLEMENTATION, spagett
func respawn():
	if(b_dead):
		return #this isn't sekiro, only die once
	#get the teleport source
	var teleport_pos : Vector2 = Vector2.ZERO
	var closest_dist_sqr  : float = INF
	for tp in game_manager.teleport_sources:
		var dist_sqr : float = global_position.distance_squared_to(tp.global_position)
		if(dist_sqr < closest_dist_sqr):
			closest_dist_sqr = dist_sqr
			teleport_pos = tp.global_position
	
	#on death
	var player_scene  = load(death_pawn_path)
	var player : PlayerPawn = player_scene.instantiate()
	get_tree().get_root().add_child(player)
	player.global_position = teleport_pos
	#possess the player
	call_deferred('finish_death', player)
	collision_mask = 0
	shape_cast.collision_mask = 0
	velocity = Vector2.ZERO
	b_dead = true
	
	
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
