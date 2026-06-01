extends PlayerAbility

@export var propulsion_power : int = 100

func trigger_ability(player : PlayerPawn) -> bool:
	#update uses and return false if uses 0 or below
	if(!super.trigger_ability(player)):
		return false
	#do propulsion
	player.velocity += (propulsion_power * player.mouse_direction)
	
	return true
