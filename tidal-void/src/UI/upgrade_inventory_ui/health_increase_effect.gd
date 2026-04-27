@tool
class_name health_increase_effect
extends base_item_effect

# to create a new effect, just extend the base class, make a new class name to access it
# below are what's special to this class. We want to increase our max health here
# you can dynamically change health ammount
@export var heal_amount = 10

func apply_effect(player: Node) -> void:
	GV.player_health += heal_amount
	print("new health is now: ", GV.player_health)
