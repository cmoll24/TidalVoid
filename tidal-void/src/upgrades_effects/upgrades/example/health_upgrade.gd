extends base_upgrade
class_name HealthUpgrade

@export var health_increase: int = 25

func apply_effect(player: Node) -> void:
	player.max_health += health_increase
	player.health = min(player.health + health_increase, player.max_health)
