extends Node2D
class_name Spawner

#Path to the scene the spawner should spawn
@export var spawn_path : String = 'res://src/'

# all spawning is actually handled by sector and world_manager, this is just an empty class
#that provides a convient way to place and see spawn points when editing a level
