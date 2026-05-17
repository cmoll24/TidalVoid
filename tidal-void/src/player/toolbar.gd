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
		abilities[type] = []
		for i in abilities_slot_max:
			abilities[type].append(null)
	add_ability_to_slot(0, typeof(Player), "propulsion_ability")

func add_ability_to_slot(index : int, type, function_name : String):
	if index < abilities_slot_max and index >= 0:
		abilities[type][index] = function_name

func call_ability(index : int, pawn : PlayerPawn):
	var pawn_type = typeof(pawn)
	var function_name = abilities[pawn_type][index]
	if function_name:
		pawn.call(function_name)
		
