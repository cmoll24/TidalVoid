@tool
class_name max_health_increase
extends base_upgrade

#this is an example of how to use the upgrade base class
#just use GV,apply_effect to let player recieve the upgrade
@export var increase_amount: int = 10

func apply_effect(player: Node) -> void:
	GV.player_health += increase_amount
	print("Max health graded to: ", GV.player_health)
