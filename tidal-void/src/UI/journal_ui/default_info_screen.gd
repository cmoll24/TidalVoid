extends Control

@onready var info_title = %creature_name
@onready var info_story = %creature_story
@onready var info_picture = %creature_image
@onready var info_adapt = %adaptation_info
@onready var info_diet = %diet_info
@onready var info_behavior = %behavior_info

func set_info(info: Dictionary):
	
	info_title.text = info["name"]
	info_story.text = info["story"]
	info_picture.texture = load(info["asset"])
	info_adapt.text = info["adapt"]
	info_diet.text = info["diet"]
	info_behavior.text = info["behavior"]
