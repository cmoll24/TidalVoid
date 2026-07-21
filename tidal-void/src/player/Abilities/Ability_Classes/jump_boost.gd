extends PlayerAbility



func trigger_ability(player : PlayerPawn) -> bool:
	#update uses and return false if uses 0 or below
	if(!super.trigger_ability(player)):
		return false
	player.jump_boost_activated(true)
	
	
	return true
