extends PlayerAbility

@export var shield_duration : float = 3.0
var shield_sprite_scene


# Called when the node enters the scene tree for the first time.
func init_ability() -> void:
	shield_sprite_scene = preload("res://src/player/Abilities/Ability_Classes/shield_sprite.tscn")
func trigger_ability(player : PlayerPawn) -> bool:
	if(!super.trigger_ability(player)):
		return false
	
	var shield_reference : ShieldSprite = shield_sprite_scene.instantiate()
	shield_reference.lifetime = shield_duration
	player.add_child(shield_reference)
	var health_component : HealthComponent = player.get_node_or_null("HealthComponent")
	if health_component != null:
		health_component.grace_period_time = shield_duration
	return true
	
