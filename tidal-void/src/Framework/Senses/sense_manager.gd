extends Node2D
class_name SenseManager

### Viewers should tie a function to this timer that calls
### check_vision to update its behavior
@onready var vision_timer : Timer

var VisionSources : Array[VisionSource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vision_timer = $VisionTimer


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
func check_vision(viewer : Node2D, sight_dist : float, v_mask : int,exceptions : Array[RID] = []) -> Array[VisionSource]:
	var out : Array[VisionSource]
	
	var space_state = get_world_2d().direct_space_state
		
	#start at the viewer
	var start : Vector2 =viewer.global_position

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
		##Perform the raycast
		
		#end at the v_source
		var end : Vector2 =  vs.parent.global_position
		
		var query = PhysicsRayQueryParameters2D.create(start, end,3,[viewer.get_rid()]+exceptions)
		
		var result = space_state.intersect_ray(query)
		
		if(result and result.collider):
			#Check if we hit the vision source
			var node := result.collider as Node
			#We assume a very specific structure and naming scheme here
			var out_vs : VisionSource = node.get_node_or_null("VisionSource")
			if(out_vs != null):
				out.append(out_vs)
	return out
	
