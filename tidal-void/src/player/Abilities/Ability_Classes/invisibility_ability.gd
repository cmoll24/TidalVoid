extends PlayerAbility


func trigger_ability(player : PlayerPawn) -> bool:
	if(!super.trigger_ability(player)):
		return false
	return true
