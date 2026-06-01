extends PlayerAbility



func trigger_ability(player : PlayerPawn) -> bool:
	#update uses and return false if uses 0 or below
	if(!super.trigger_ability(player)):
		return false
	#do teleport
	#teleport to the nearest teleport source
	var teleport_pos : Vector2 = Vector2.ZERO
	var closest_dist_sqr  : float = INF
	for tp in player.game_manager.teleport_sources:
		var dist_sqr : float = player.global_position.distance_squared_to(tp)
		if(dist_sqr < closest_dist_sqr):
			closest_dist_sqr = dist_sqr
			teleport_pos = tp
	#perform teleportation
	player.global_position = teleport_pos
	#stop leftover velocity
	player.velocity = Vector2.ZERO
	return true
