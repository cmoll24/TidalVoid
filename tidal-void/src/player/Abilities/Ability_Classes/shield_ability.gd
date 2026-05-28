extends PlayerAbility

@export var shield_duration : float = 3.0


var shield_sprite_scene

var shield_reference : ShieldSprite

# Called when the node enters the scene tree for the first time.
func init_ability() -> void:
	shield_sprite_scene = preload("res://src/player/Abilities/Ability_Classes/shield_sprite.tscn")
func trigger_ability(player : PlayerPawn) -> bool:
	#prevent overlapping uses
	if(shield_reference):
		return false
	
	#update uses and return false if uses 0 or below
	if(!super.trigger_ability(player)):
		return false
	
	#instantiate a new shield sprite
	shield_reference  = shield_sprite_scene.instantiate()
	shield_reference.lifetime = shield_duration
	player.add_child(shield_reference)
	
	#grant the player a grace period on damage
	var health_component : HealthComponent = player.get_node_or_null("HealthComponent")
	if health_component != null:
		health_component.grace_period_time = shield_duration
	return true
	
