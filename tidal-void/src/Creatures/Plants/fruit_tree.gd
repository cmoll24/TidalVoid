extends Plant
class_name FruitTree

@export var fruit_spawn_offset : Vector2 

@export var max_fruit_velocity_boost : float = 80

var game_manager : GameManager

var dominant_body : GravitySource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# initialize dominant body and game manager
	game_manager = get_tree().get_first_node_in_group("game_managers")
	var closest_dist = INF
	for body in game_manager.gravity_sources:
		var dist = body.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			closest_dist = dist
			dominant_body = body
			
func play_open_anim() -> void:
	anim_player.play("fruit_tree_open")
	get_tree().create_timer(1.2).timeout.connect(release_fruit)

func release_fruit() -> void:
	## spawn a fruit
	var fruit_scene  = preload("res://src/Collectables/fruit1.tscn")
	var fruit : Collectable = fruit_scene.instantiate()
	get_tree().get_root().add_child(fruit)
	var spawn_pos : Vector2 = global_position + fruit_spawn_offset.rotated(global_rotation)
	fruit.b_start_in_orbit = false
	fruit.global_position = spawn_pos
	#give it a random orbital velocity
	fruit.velocity = GameManager.orbital_velocity(dominant_body,spawn_pos)
	if(randf() > 0.5):
		fruit.velocity = -fruit.velocity
	fruit.velocity += randf()*max_fruit_velocity_boost*global_transform.basis_xform(Vector2.UP)
	#play open animation in reverse
	anim_player.play("fruit_tree_open",-1,-1,true)
	
