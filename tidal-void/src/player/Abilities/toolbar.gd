class_name  Toolbar
extends CanvasLayer
#We have too many upgrade ideas, we have lots of ideas
# takes in inputs from the Player Controller
var abilities : Dictionary
# abilites length should be however big the upgrade slots
var abilities_slot_max : int = 4

#The list should store the current loadout, store before toolbar slots
#store the information for each upgrade somewhere else


func _ready() -> void:
	for type in PlayerPawn.pawn_types:
		var empty_array : Array= []
		for i in range(abilities_slot_max):
			empty_array.append(null)
		abilities[type] = empty_array
		for i in abilities_slot_max:
			abilities[type].append(null)
	add_ability_to_slot(0, typeof(Player), "res://src/player/Abilities/Ability_Classes/propulsion_ability.tscn")
	add_ability_to_slot(1, typeof(Player), "res://src/player/Abilities/Ability_Classes/teleport_ability.tscn")
	add_ability_to_slot(2, typeof(Player), "res://src/player/Abilities/Ability_Classes/boost_ability.tscn")
	add_ability_to_slot(3, typeof(Player), "res://src/player/Abilities/Ability_Classes/shield_ability.tscn")
func add_ability_to_slot(index : int, type, ability_path : String):
	if index < abilities_slot_max and index >= 0:
		#delete the old ability if there is one
		var old_ability : PlayerAbility = abilities[type][index]
		if(old_ability):
			old_ability.deinit_ability()
			old_ability.queue_free()
		#make a new instance
		var new_ability : PlayerAbility =load(ability_path).instantiate()
		new_ability.init_ability()
		abilities[type][index] = new_ability
		

func call_ability(index : int, pawn : PlayerPawn):
	var pawn_type = typeof(pawn)
	var ability : PlayerAbility = abilities[pawn_type][index]
	if(ability):
		ability.trigger_ability(pawn)

func reset_abilities():
	for pawn_type in abilities:
		print(pawn_type)
		for ability in abilities[pawn_type]:
			if ability is PlayerAbility:
				ability.reset_uses()
		
