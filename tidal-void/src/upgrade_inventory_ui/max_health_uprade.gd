@tool
class_name max_health_upgrade
extends base_upgrade

@export var increase_amount: float = 10.0

func apply_effect(player: Node) -> void:
	GV.player_health += increase_amount
	print("Max health increased to: ", GV.player_health)
