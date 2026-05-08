extends Node2D
class_name ShroudComposite

var shroud_lookup : Dictionary
# for performance, shrouds are placed into "tiles" in a dictionary so only ones in a tile are updated
@export var shroud_tile_size = 200

var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get the game manager
	game_manager = get_tree().get_first_node_in_group("game_managers")
	#index all children
	for node in get_children():
		if(node is TextureRect):
			var tiles = []
			##assumes equal size in all dimensions
			var size : float = node.size.x * node.scale.x
			var center_position = node.global_position + Vector2(size,size)/2
			#check all corners of tshe shape to ensure it is included in relavant tiles
			for x in range(-1,2):
				for y in range(-1,2):
					var offset = Vector2(x,y)
					var tile : Vector2 = ((center_position+ offset*size)/shroud_tile_size).round()
					if(tiles.find(tile) == -1):
						#add the tile if it wasn't there before
						tiles.append(tile)
			for tile in tiles:
				# add this node to the corresponding tiles
				shroud_lookup.get_or_add(tile,[]).append(node)	
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	#Fade shrouds out when they are near a light source/player
	for body in game_manager.revealing_sources:
		var tile_coords : Vector2 = (body.global_position/ shroud_tile_size).round()
		var nodes = shroud_lookup.get(tile_coords)
		if(nodes):
			for node in nodes:
				#fade the shroud out based on the player's proximity
				#we actually want this to be squared for smooth transition
				var size = node.size.x * node.scale.x
				var dist_sqr = body.global_position.distance_squared_to(node.global_position+Vector2(size,size)/2)
				var alpha : float = dist_sqr/(size**2)
				node.self_modulate = Color(1,1,1,alpha)
