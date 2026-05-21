extends Node2D
###the general manager for world events and working across multiple sectors
class_name WorldManager

@export var sectors : Array[Sector]

#minimum time between meteor showers
@export var min_meteor_shower_time : float = 35

#maximum time between meteor showers
@export var max_meteor_shower_time : float = 70

#the time between the "start" of the meteor shower and when meteors start actually hitting, gives the player some warning time
@export var meteor_shower_warning_time : float = 8

#How long the meteor shower lasts(programmatically, when the things actually get respawned), the particle effect should be longer than this duration
@export var meteor_shower_duration : float = 2

#broadcasts when a meteor shower starts, example usage: giving the player an early warning to get to cover
signal on_meteor_shower_start()

#the meteor shower particles that play as a warning before the actual shower occurs
@onready var meteor_shower_warning_particles : GPUParticles2D = $MinorMeteorShowerParticles


#the meteor shower particles that play when the meteor shower is actively taking place
@onready var meteor_shower_main_particles : GPUParticles2D = $MajorMeteorShowerParticles



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Start the meteor shower eventually
	get_tree().create_timer(randf_range(min_meteor_shower_time,max_meteor_shower_time)).timeout.connect(start_meteor_shower_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#temp code, keeps the paritcles on target with the player
	if(GV.player_node):
		meteor_shower_main_particles.global_position = GV.player_node.global_position
	
# this begins the process of the meteor shower, showing warning signs, and preparing for the actual event
func start_meteor_shower_event():
	#broadcast the the shower is starting
	on_meteor_shower_start.emit()
	#position and play the warning particles
	if(GV.player_node):
		meteor_shower_warning_particles.global_position = GV.player_node.global_position
	meteor_shower_warning_particles.emitting = true
	#begin performance of the meteor shower after the warning time had progressed
	get_tree().create_timer(meteor_shower_warning_time).timeout.connect(perform_meteor_shower_event)

func perform_meteor_shower_event():
	#play main stage particles
	if(GV.player_node):
		meteor_shower_main_particles.global_position = GV.player_node.global_position
	meteor_shower_main_particles.emitting = true
	
	### TO BE IMPLEMENTED
	#deal damage to player if they are not behind the cover of a planet
	
	#programmatically finish the event
	get_tree().create_timer(meteor_shower_duration).timeout.connect(finish_meteor_shower_event)

func finish_meteor_shower_event():
	#respawn all spawners
	for sector in sectors:
		for spawn_point : Dictionary in sector.spawn_points:
			#respawn things only if they don't have something currently spawned, or marked to be spawned
			if(!spawn_point['respwn_on_ld'] && !spawn_point['curr_obj']):
				if(sector.loaded):
					#if the sector is loaded, simply respawn
					var new_object : Node2D = load(spawn_point['path']).instantiate()
					new_object.global_position = spawn_point['pos']
					get_tree().root.add_child(new_object)
					spawn_point['curr_obj'] = new_object
				else:
					#if the sector isn't loaded, mark the spawn point so it can be respawned when it is loaded
					spawn_point['respwn_on_ld'] = true
				
	
	#restart the event later
	get_tree().create_timer(randf_range(min_meteor_shower_time,max_meteor_shower_time)).timeout.connect(start_meteor_shower_event)
