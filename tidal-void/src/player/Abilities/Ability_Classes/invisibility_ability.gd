extends PlayerAbility

@onready var player_sprite : Sprite2D = $PlayerSprite

func trigger_ability(player : PlayerPawn) -> bool:
	print("test")
	
	return true
