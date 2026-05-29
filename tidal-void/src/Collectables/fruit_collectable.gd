extends Collectable
class_name FruitCollectible

@export var lifetime : float = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# only go into orbit a little after starting 
	get_tree().create_timer(1.5).timeout.connect(start_orbit)
	
func start_orbit() -> void:
	velocity = GameManager.orbital_velocity(get_dominant_body(),global_position)
	if(!b_start_in_orbit_dir):
		velocity = -velocity
		
		
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# die when lifetime runs out(prevents too many fruits from spawning)
	lifetime -= delta
	if(lifetime <= 0):
		die()
	
func die():
	queue_free()

		
func save() -> Dictionary:
	var node_data : Dictionary = super.save()
	node_data.merge({'lifetime' = lifetime})
	return node_data
	
func load_state(node_data : Dictionary):
	super.load_state(node_data)
	lifetime = node_data['lifetime']
