extends Bubble
class_name CreatureStorage

var move_speed : float = 50.0
var slow_radius : float = 100.0
var acceleration : float = 10.0

var target_position : Vector2 = Vector2.ZERO

var move_velocity : Vector2 = Vector2.ZERO

@onready var creature_detector : Area2D = $CreatureDetector

func _ready() -> void:
	super._ready()
	target_position = position
	GV.player_inventory.creature_storage = self;

func set_target_position(new_target : Vector2):
	target_position = new_target

func _physics_process(delta: float) -> void:
	var target_vec : Vector2 = target_position - position
	var distance : float = target_vec.length()
	
	if distance < 1.0:
		move_velocity = Vector2.ZERO
		position = target_position
		super._physics_process(delta)
	
	var direction : Vector2 = target_vec/distance if distance > 0.001 else Vector2.ZERO # normalize
	
	var target_speed : float = move_speed
	if distance < slow_radius:
		#gradually reduce speed linearly as distnace approaches
		target_speed = move_speed * (distance / slow_radius)
	
	var target_velocity : Vector2 = direction * target_speed
	
	move_velocity = move_velocity.move_toward(target_velocity, acceleration * delta)
	
	global_position += move_velocity * delta
	
	#Determine velocity for creatures in bubble
	velocity = move_velocity

### not a trival function, only call when needed
func get_stored_creatures() -> Dictionary[Creature.crafting_type, int]:
	##The creature list is a dictionary where 
	##             the key is they type of creature
	##             and the value is the number of creatures
	var stored_creatures : Dictionary[Creature.crafting_type, int] = {}

	#go through every overlapping body	
	for body in creature_detector.get_overlapping_bodies():
		if body is Creature:
			var creature_type : Creature.crafting_type = body.creature_type
			if stored_creatures.has(creature_type):
				stored_creatures[creature_type] += 1
			else:
				stored_creatures[creature_type] = 1
				
	return stored_creatures

#changes the dictionary gotten from get_stored_creature into the format of items, with string names
static func stored_creatures_to_items(dict : Dictionary[Creature.crafting_type, int]) -> Array:
	var out : Array = []
	for k in dict.keys():
		out.append({"item_name" : Creature.crafting_type_to_name_table[k],
		"quantity" : dict[k]})
	return out;
