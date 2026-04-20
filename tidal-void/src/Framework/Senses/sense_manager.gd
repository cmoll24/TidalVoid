extends Node
class_name SenseManager

### Viewers should tie a function to this timer that calls
### check_vision to update its behavior
@onready var vision_timer : Timer

@onready var vision_raycast : RayCast2D

var VisionSources : Array[VisionSource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vision_timer = $VisionTimer
	vision_raycast = $VisionRayCast
	#prevent it from sapping performance by updating every tick
	vision_raycast.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func register_vision_source(source : VisionSource) -> void:
	VisionSources.append(source);
	
func unregister_vision_source(source : VisionSource) -> void:
	VisionSources.erase(source);

###Performs a raycast to all VisionSources(ignoring the viewer)
###and returns anything the viewer can see
### use v_mask to include all the vision source types that matter, ie v_source_type.x | v_source_type.y
func check_vision(viewer : Node2D, sight_dist : float, v_mask : int) -> Array[VisionSource]:
	var out : Array[VisionSource]
	#Configure the raycast for the viewer
	vision_raycast.clear_exceptions()
	vision_raycast.add_exception(viewer)
	vision_raycast.global_position = viewer.global_position
	#avoid taking expensive(not that expensive) square roots
	var sight_dist_squared = sight_dist*sight_dist;
	# check all the vision sources
	for vs in VisionSources:
		if(!((1 << vs.v_type) & v_mask)):
			# skip if the the vision source doesn't fit the bitmask
			continue
		if((viewer.global_position - vs.parent.global_position).length_squared() > sight_dist_squared):
			#if it is too far away, don't check it
			continue
		if(!vs || !vs.parent):
			continue
		#Perform the raycast
		vision_raycast.target_position = vs.parent.global_position
		vision_raycast.force_raycast_update();
		if(vision_raycast.get_collider()):
			#Check if we hit the vision source
			var node := vision_raycast.get_collider() as Node
			#We assume a very specific structure and naming scheme here
			var out_vs : VisionSource = node.get_node_or_null("VisionSource")
			if(out_vs != null):
				out.append(out_vs)
	return out
	
