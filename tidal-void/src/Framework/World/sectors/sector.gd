extends Node2D
class_name Sector

#the name of the file to store sector data when the sector is unloaded, concatenated onto 'user://savegame.' on startup
@export var file_name : String= 'dusk_sector'

@export var load_buffer_margin : float = 1000

#delay before unloaded when all streaming sources have left the area, prevents rapid loading and unloading when the player is skirting the edge
@export var unload_delay : float = 3

#the number of json lines to read and process every frame when loading
@export var lines_per_frame_load : int = 1

var time_to_unload : float = 0

@onready var ref_rect : ReferenceRect = $ReferenceRect

var SAVE_PATH : String = 'user://savegame.'

var load_area_size :Vector2 
var load_area_pos : Vector2 

var loaded : bool = false

var force_load_unload : bool = true

### built at runtime, format:
### pos :Vector2
### path : String = to scene to instantiate
### curr_obj : Node = a reference to the currently spawned object if there is one
### had_curr_obj : bool = saves whether a curr obj existed when last unloaded
### respwn_on_ld : bool = true if this needs to be respawned
var spawn_points : Array[Dictionary] = []

var game_manager : GameManager

var loaded_before : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get the game manager
	game_manager = get_tree().get_first_node_in_group('game_managers')
	#complete the save path
	SAVE_PATH = SAVE_PATH+file_name
	#save data from the ref rect
	load_area_size = ref_rect.size * ref_rect.scale
	load_area_pos = ref_rect.global_position
	# delete the ref rect, it has served its purpose
	ref_rect.queue_free()
	remove_child(ref_rect)
	
	#unpack all the spawn point info 
	unpack_spawn_points()
	
	# DEBUG ONLY, wipe save data on every new run to allow for easy testing
	if(OS.is_debug_build()):
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(SAVE_PATH)
	
func _physics_process(delta: float) -> void:
	#deincrement the unload timer
	time_to_unload -= delta
	# check for streaming sources in bounds
	for source in game_manager.streaming_sources:
		if(_in_bounds(source.global_position,load_buffer_margin)):
			#if one was found, reset the unload timer
			time_to_unload = unload_delay
			#reload the area if it was unloaded
			if(!loaded || force_load_unload):
				load_sector()
			break;
	#unload if we have gone too long without a streaming source
	if((loaded || force_load_unload)) && time_to_unload <= 0:
		unload_sector()

func unload_sector():
	#set loaded status
	loaded = false
	force_load_unload = false
	#update the current object status of all the spawn points
	for spawn_point in spawn_points:
		if(spawn_point['curr_obj']):
			spawn_point['had_curr_obj'] = true
		else:
			spawn_point['had_curr_obj'] = false
	#open the save file
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	#all children are automatically added and dynamic nodes will be added if in proximity
	
	#Save all the children
	for node in get_children():
		if(node is InstancePlaceholder || node.is_queued_for_deletion()):
			continue; #ignore placeholders and dying nodes
		save_and_unload_node(node,save_file,false)
		
	#now get all dynamic actors within range
	for node in get_tree().get_nodes_in_group("dynamic_save"):
		#assume everything is node2D, if it isn't it will crash, but that is intended behavior
		if(!node.is_queued_for_deletion() && _in_bounds(node.global_position)):
			save_and_unload_node(node,save_file,true)
			
func load_sector():
	#set loaded status
	loaded = true
	force_load_unload = false
	
	#first load if applicable
	if(!loaded_before):
		#on first load, unpack the instance placeholders and build the spawn points
		var placeholders_till_wait : int = lines_per_frame_load
		for node in get_children():
			if(node and node is InstancePlaceholder):
				#asynchonously load the assets
				var scene = await async_load(node.get_instance_path());
				if(!scene):
					printerr("instance placeholder was invalid, path: %s" % node.get_instance_path())
					continue
				#now run create instance
				node.create_instance(true)
				#print("loaded placeholder from path %s for sector %s" % [node.get_instance_path(),file_name])
				
				#spread the load across multiple frames
				placeholders_till_wait -= 1
				if(placeholders_till_wait <= 0):
					#wait for a couple frames
					await get_tree().process_frame
					await get_tree().process_frame
					#reset the wait
					placeholders_till_wait = lines_per_frame_load;
				
	#respawn anything if applicable
	for spawn_point : Dictionary in spawn_points:
		#if the spawn point is marked to be respawned on load, and it has nothing spawned, respawn it
		if(spawn_point['respwn_on_ld'] && !spawn_point['had_curr_obj']):
			spawn_point['respwn_on_ld'] = false
			#asynchonously load the assets
			var scene = await async_load(spawn_point['path']);
			if(!scene):
				printerr("spawn point path %s could not be loaded, spawn aborted" % spawn_point['path'])
				continue
			#instantiate and intialize the object
			var new_object : Node2D = scene.instantiate()
			new_object.global_position = spawn_point['pos']
			get_tree().root.add_child(new_object)
			#save a reference to the object
			spawn_point['curr_obj'] = new_object
			
	#check to see if a file exists
	if not FileAccess.file_exists(SAVE_PATH):
		if(loaded_before):
			printerr("load called on sector, '%s' without a save file" % file_name)
		return # Error! We don't have a save to load.
		
	
	#open the save file
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	#iterate through the file
	var lines_till_wait : int = lines_per_frame_load
	while save_file.get_position() < save_file.get_length():
		#get the line
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data : Dictionary = json.data

		# First, we need to create the object and add it to the tree and set its position.
		
		#asynchronously load it
		var scene = await async_load(node_data["path"]);
		if(!scene):
			printerr("sector %s could not load path %s, load aborted" % [file_name,node_data["path"]])
			continue
		#instantiaate the object
		var new_object : Node2D = scene.instantiate()
		
		#spread the load across multiple frames
		lines_till_wait -= 1
		if(lines_till_wait <= 0):
			#wait for a couple frames
			await get_tree().process_frame
			await get_tree().process_frame
			#reset the wait
			lines_till_wait = lines_per_frame_load;
		
		#finish initializing
		new_object.global_position = Vector2(node_data["pos_x"], node_data["pos_y"])
		new_object.global_rotation = node_data["rot"]
		#check to see if this was spawned by a spawn point
		var spawn_index : int = node_data.get('spawn_point',-1)
		if(spawn_index != -1):
			#check that the index is valid and then sanity check with the position to ensure it originated in the right sector
			if(spawn_index < spawn_points.size()):
				var spawn_point = spawn_points[spawn_index]
				if spawn_point['pos'].x == node_data['spawn_point_x']:
					#set the current object
					spawn_points[spawn_index]['curr_obj'] = new_object
			
			
		if(node_data["dynamic_save"]):
			#if dynamic, add it to the scene root
			get_tree().root.add_child(new_object)
		else:
			#if static add it as child
			add_child(new_object)
			
		#now feed the node back its save data if it has a load function
		if(new_object.has_method('load_state')):
			new_object.load_state(node_data)
				
	#save that this is not the first load
	loaded_before = true	
		
func save_and_unload_node(node :Node,save_file,b_dynamic_save : bool):
	#print an error if the child is not a scene instance(do not put things as children of each other, each instance should be a top level child)
	if(node.scene_file_path.is_empty()):
		if(node is InstancePlaceholder):
			#ignore placeholders
			pass
		else:
			print("node '%s' in sector '%s' is not an instanced scene, save skipped" % [node.name,file_name])
		return
	#store the data as a dict for flexibility
	
	#first save the basic universal info
	var node_data : Dictionary = {"path" : node.scene_file_path,
		"pos_x" : node.global_position.x,
		"pos_y" : node.global_position.y,
		"rot" : node.global_rotation,
		"dynamic_save" : b_dynamic_save}
	#save its spawn point if applicable
	if(b_dynamic_save):
		for i in range(spawn_points.size()):
			if(node ==spawn_points[i]['curr_obj']):
				#save the index of the spawn point
				node_data['spawn_point'] = i
				#save the x coord of the spawn point to perform a sanity check with
				#prevents issues with index mismatches caused by things moving between sectors or the removal/addition
				#of spawn points causing issues with old saves
				node_data['spawn_point_x'] = spawn_points[i]['pos'].x
	
	#run the save function if it has one
	if(node.has_method('save')):
		#merge any extra save data in, allowing for default keys to be overwritten by the save function
		node_data.merge(node.save(),true) 
		
	#run the unload function if it has one
	if(node.has_method('unload')):
		node.unload()
		
	#delete the node now that it is prepared
	node.queue_free()
	
	#get the data as string
	var json_string = JSON.stringify(node_data)
	#save the data
	save_file.store_line(json_string)
	
#custom rect check, may be slightly faster than normal check as it doesn't take rotations into account and supports a margin
func _in_bounds(pos : Vector2, margin : float = 0) -> bool:
	#do basic rectangle bounds check
	if(pos.x < load_area_pos.x - margin):
		return false
	if(pos.x > load_area_pos.x+load_area_size.x+margin):
		return false
	if(pos.y < load_area_pos.y - margin):
		return false
	if(pos.y > load_area_pos.y+load_area_size.y+margin):
		return false
		
	#if we are between all the sides, we are in the rectangle
	return true

func unpack_spawn_points():
	for node in get_children():
		if(node is Spawner):	
			var spawn_point : Dictionary = {
				pos = node.global_position,
				path = node.spawn_path,
				curr_obj = null,
				had_curr_obj = false,
				respwn_on_ld = true
				}
			spawn_points.append(spawn_point)
			#Delete the node now that the data is extracted from it
			node.queue_free()


func async_load(path : String) -> Variant:
	#start loading
	ResourceLoader.load_threaded_request(path)
	#wait for load to complete
	while(true):
		#get the status
		var status : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path);
		match status:
			ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				printerr("Invalid path sent to sector: %s asnyc_load, path: %s" % [file_name,path])
				return null
			ResourceLoader.THREAD_LOAD_LOADED:
				#success, fully loaded
				return ResourceLoader.load_threaded_get(path)
			_:
				#not loaded yet await next frame
				await get_tree().process_frame
				
	return null;
		
		
		
		
		
