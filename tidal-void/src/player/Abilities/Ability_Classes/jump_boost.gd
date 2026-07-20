extends PlayerAbility

@export var jump_power : int = 100

func trigger_ability(player : PlayerPawn) -> bool:
	#update uses and return false if uses 0 or below
	
	player.jump_boost_activated(true)
	
	
	return true
