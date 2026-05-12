extends Node2D
class_name Sector

#the name of the file to store sector data when the sector is unloaded, concatenated onto 'user://savegame.' on startup
@export var file_name : String= 'dusk_sector'

@export var load_buffer_margin : float = 1000

@onready var ref_rect : ReferenceRect = $ReferenceRect

var SAVE_PATH : String = 'user://savegame.'

var load_area_size :Vector2 
var load_area_pos : Vector2 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#complete the save path
	SAVE_PATH = SAVE_PATH+file_name
	#save data from the ref rect
	load_area_size = ref_rect.size * ref_rect.scale
	load_area_pos = ref_rect.global_position
	# delete the ref rect, it has served its purpose
	ref_rect.queue_free()
	
func unload_sector():
	#open the save file
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	#all children are automatically added and dynamic nodes will be added if in proximity
	
	#Save all the children
	for node in get_children():
		save_and_unload_node(node,save_file,false)
		
	#now get all dynamic actors within range
	for node in get_tree().get_nodes_in_group("dynamic_save"):
		#assume everything is node2D, if it isn't it will crash, but that is intended behavior
		if(_in_bounds(node.global_position)):
			save_and_unload_node(node,save_file,true)
			
func load_sector():
	if not FileAccess.file_exists(SAVE_PATH):
		printerr("load called on sector, '%s' without a save file" % file_name)
		return # Error! We don't have a save to load.
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data

		# First, we need to create the object and add it to the tree and set its position.
		var new_object : Node2D = load(node_data["path"]).instantiate()
		new_object.global_position = Vector2(node_data["pos_x"], node_data["pos_y"])
		if(node_data["dynamic_save"]):
			#if dynamic, add it to the scene root
			get_tree().root.add_child(new_object)
		else:
			#if static add it as child
			add_child(new_object)
			
		#now feed the node back its save data if it has a load function
		if(new_object.has_method('load')):
			new_object.load(node_data)
		
func save_and_unload_node(node :Node,save_file,b_dynamic_save : bool):
	#print an error if the child is not a scene instance(do not put things as children of each other, each instance should be a top level child)
	if(node.scene_file_path.is_empty()):
		print("node '%s' in sector '%s' is not an instanced scene, save skipped" % [node.name,file_name])
		return
	#store the data as a dict for flexibility
	var node_data : Dictionary 
	#run the save function if it has one
	if(node.has_method('save')):
		node_data = node.save()
	else:
		#if there is no dedicated save function, save the path of the actor
		node_data = {"path" : node.scene_file_path,
		"pos_x" : node.global_position.x,
		"pos_y" : node.global_position.y,
		"dynamic_save" : b_dynamic_save}
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
