class_name Creature
extends DriftBody

enum size_type {none ,small ,medium ,large ,leviathan}
enum crafting_type {
	jeremiah,
	steven,
	leaper,
	evil_fred,
	hungry_harry,
	charlotte,
	star_ray
}

static var crafting_type_to_name_table : Dictionary[crafting_type,String] = {
	crafting_type.jeremiah : 'Jeremiah',
	crafting_type.steven : 'Steven',
	crafting_type.leaper : 'Leaper',
	crafting_type.evil_fred : 'Evil Fred',
	crafting_type.hungry_harry : 'Hungry Harry',
	crafting_type.charlotte : 'Charlotte',
	crafting_type.star_ray : 'Star Ray',
}

### if greater than 0, behavior is disabled and time will be brought down
@export var stun_time : float = 0

@export var creature_size : Creature.size_type = size_type.small

@export var creature_type : Creature.crafting_type 

@onready var health_comp : HealthComponent = $HealthComponent

var b_dead : bool = false

func _ready() -> void:
	super._ready()
	start_in_orbit = true
	health_comp.on_death.connect(die)
	health_comp.on_take_damage.connect(on_take_damage)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	#decrement stun time
	stun_time -= delta
	# run creature movement
	creature_movement(delta)

func creature_movement(delta):
	pass
	
func get_square_altitude(body : GravitySource):
	return global_position.distance_squared_to(body.global_position)
	

func on_collide_with_other_drift_body(other : DriftBody) -> void:
	super.on_collide_with_other_drift_body(other)
	if other is Player:
		GV.discover_creature(creature_type)

func on_collide_with_bubble(bubble : Bubble) -> void:
	super.on_collide_with_bubble(bubble)
	GV.discover_creature(creature_type)
	
func die():
	if(!b_dead):
		b_dead = true
		queue_free();
		
func on_take_damage(damage : float, dmg_type : HealthComponent.e_dmg_types, damage_causer : Node2D = null, instigator : Node = null):
	match dmg_type:
		HealthComponent.e_dmg_types.grab:
			stun_time = damage
		_:
			pass
	
func save():
	var node_data : Dictionary = {
		"health_dict" : health_comp.save()
	}
	node_data.merge(super.save())
	return node_data

func load_state(node_data : Dictionary):
	health_comp.load_state(node_data["health_dict"])
	super.load_state(node_data)
