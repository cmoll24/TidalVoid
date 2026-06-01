extends Node
class_name PlayerAbility

@export var max_uses : int = 1

var uses : int = 1



func init_ability() -> void:
	uses = max_uses

# attempts to trigger the ability, returns false if the ability could not be triggerd(out of uses)
func trigger_ability(player : PlayerPawn) -> bool:
	if(uses <= 0):
		return false
	uses -= 1
	return true
	
# called when an ability is unequipped before destruction
func deinit_ability()->void:
	pass
	
func reset_uses():
	uses = max_uses
