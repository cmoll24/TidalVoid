extends base_upgrade
class_name AbilityUnlockUpgrade

@export var ability_slot : int = 0
@export var ability_path : String = "res://src/player/Abilities/Ability_Classes/propulsion_ability.tscn"

func apply_effect(player: Node) -> void:
	var player_true : Player = player as Player
	if(player_true):
		player_true.controller.toolbar. \
		add_ability_to_slot(ability_slot, typeof(Player), ability_path)
		
func remove_effect(player: Node) -> void:
	var player_true : Player = player as Player
	if(player_true):
		player_true.controller.toolbar. \
		remove_ability_from_slot(ability_slot, typeof(Player))
