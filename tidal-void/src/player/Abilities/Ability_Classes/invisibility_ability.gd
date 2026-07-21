extends PlayerAbility

var timer : Timer
@export var invisibility_duration = 10
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 10.0
	timer.one_shot = true
	add_child(timer)
	
func trigger_ability(player : PlayerPawn) -> bool:
	player.visible = false
	
	
	return true
	
func _on_timer_timeout() -> void:
	print("done")
	pass # Replace with function body.
