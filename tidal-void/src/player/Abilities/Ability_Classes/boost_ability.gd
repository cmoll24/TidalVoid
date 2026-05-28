extends PlayerAbility

### multiplier applied to thrust during the boost
@export var boost_multiplier : float = 5.0;
### duration of the boost
@export var boost_time : float = 1.5
var is_boosting : bool = false
#saves the last set player ref
var player_ref : PlayerPawn

func trigger_ability(player : PlayerPawn) -> bool:
	#you cannot boost when already boosting
	if(is_boosting): 
		return false
	#update uses and return false if uses 0 or below
	if(!super.trigger_ability(player)):
		return false
	#save player ref
	player_ref = player
	
	#do boost
	is_boosting = true
	player.thrust_multiplier = boost_multiplier
	#stop boost later
	player.get_tree().create_timer(boost_time).timeout.connect(stop_speed_boost)
	
	return true

func stop_speed_boost():
	is_boosting = false
	if(player_ref):
		player_ref.thrust_multiplier = 1
	
	
func _exit_tree() -> void:
	#make sure that the speed boost stops even if this is deleted
	stop_speed_boost()
