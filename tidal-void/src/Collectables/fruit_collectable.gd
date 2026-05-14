extends Collectable
class_name FruitCollectible

var fruit_tree : FruitTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# only go into orbit a little after starting 
	get_tree().create_timer(1).timeout.connect(start_orbit)
	
func start_orbit() -> void:
	velocity = GameManager.orbital_velocity(get_dominant_body(),global_position)
	if(!b_start_in_orbit_dir):
		velocity = -velocity
		
func _exit_tree() -> void:
	#decrement the fruit count
	if(fruit_tree):
		fruit_tree.fruit_count -= 1
