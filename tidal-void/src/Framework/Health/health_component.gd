extends Node
#Place as direct child with the name HealthComponent, manages health, death and status effects
class_name HealthComponent

###physical damage damages health, heat damage interprets damage as the heat value, 
###knockback does well, knockback based on the damage value(velocity length = damage), requires parent class to be a drift body and a damage causer to be set
###grab damage does nothing by default but is open for custom implementations (connect the on take damage signal) (damage should be low, interpretted as stun time(seconds) in creatures)
###none damage exists only as a default value, it will do nothing and print an error if used
enum e_dmg_types {none,physical,heat,knockback,grab}

###the maximum health(health defaults to this value at start)
@export var max_health : float = 100

###the current health
var health :float 

###the default temperature to go to when not exposed to heat or cold
@export var body_temperature : float = 37

#the current temperature
var temperature : float

###43 celcius causes death in humans for reference(our player has a suit, so maybe a little tougher), space creatures are also likely tough
### to clarify, this isn't instant death damage, but rather the limit at which survival becomes uncomfortable, health will start to decrease
### when temperature goes beyond this limit, the rate of decrease will scale based on how far the limit is breached
@export var heat_tolerance : float = 50

###the speed per second at which temperature will be regulated to body temperature
@export var heat_regulation_speed : float = 20

### the initial grace period time(cannot take damage)on spawning(can also be directly set to some value, it will decrement itself automatically)
@export var grace_period_time :float = 0.1

#cooldowns for certain damage types to prevent taking repeat damage from the same thing
var phys_dmg_cooldown : float = 0

var knockback_cooldown : float = 0
#saves a reference to the parent for convenience
var parent : Node

signal on_death()

signal on_take_damage(damage : float, dmg_type : e_dmg_types, damage_causer : Node, instigator : Node)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#initialize values
	health = max_health
	temperature = body_temperature
	parent = get_parent()

#do not modify health directly, rather call this function for damage, damage_causer is the direct cause of damage(i.e. the sword)
#instigator is the node behind the damager causer(i.e. knight holding the sword)
#These can be used for things like showing a directional damage indicator towards the source, knockback and creature aggression towards things that damage it
func take_damage(damage : float, dmg_type : e_dmg_types, damage_causer : Node2D = null, instigator : Node = null):
	#skip damage while in grace period
	if(grace_period_time > 0):
		return
	#broadcast damage event
	on_take_damage.emit(damage,dmg_type,damage_causer,instigator)
	#case based response to damage
	match dmg_type:
		e_dmg_types.physical:
			if(phys_dmg_cooldown <= 0):
				set_health(health - damage)
				phys_dmg_cooldown = 0.1
		e_dmg_types.knockback:
			if(knockback_cooldown <= 0 && damage_causer && parent is DriftBody):
				parent.velocity += (parent.global_position - damage_causer.global_position).normalized() * damage
				knockback_cooldown = 0.1
		e_dmg_types.heat:
			temperature = damage
		e_dmg_types.grab:
			pass
		_:
			var damage_causer_name : String = String(damage_causer.name) if damage_causer else 'null';
			var instigator_name : String = String(instigator.name) if instigator else 'null';
			printerr("%s took none damage(an unset damage type), caused by %s, instigated by %s " % [parent.name, damage_causer_name,instigator_name])
		
	
#setter for health, never set health directly
func set_health(new_health : float):
	health = clamp(new_health,0,max_health)
	if(health <= 0):
		on_death.emit()
		
func _process(delta: float) -> void:
	#decrement grace period and damage cooldowns
	grace_period_time -= delta
	phys_dmg_cooldown -= delta
	knockback_cooldown -= delta
	#deal damage if temperature is too high
	if(temperature > heat_tolerance):
		var damage : float = (temperature - heat_tolerance)*delta
		set_health(health - damage)
		
	#regulate temperature
	temperature = move_toward(temperature,body_temperature,heat_regulation_speed*delta)
	
### IMPORTANT: HealthComponent is not a top level node, sector.gd will NOT call this, it must be called manually in the parent's save function, adding it onto the save dict
### Example usage: in save() -> {health_dict : health_component.save()}

func save():
	return {
		hp = health,
		temp = temperature
	}
	
### IMPORTANT: HealthComponent is not a top level node, sector.gd will NOT call this, it must be called manually in the parent's load function, feeding it back its dict from the save function
### Example usage: in load_state() -> health_component.load_state(save_data[health_dict])
func load_state(health_data : Dictionary):
	health = health_data['hp']
	temperature = health_data['temp']
	
	
