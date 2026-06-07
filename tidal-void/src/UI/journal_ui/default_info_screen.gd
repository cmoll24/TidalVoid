extends Control

@onready var details_box = %DetailsBox

@onready var info_title = %creature_name
@onready var info_story = %creature_story
@onready var info_picture = %creature_image
@onready var info_adapt = %adaptation_info
@onready var info_diet = %diet_info
@onready var info_behavior = %behavior_info

func set_info(info: Dictionary):
	
	info_title.text = info["name"]
	info_picture.texture = load(info["asset"])
	
	if info["found"]:
		details_box.show()
		info_story.text = info["story"]
		info_adapt.text = info["adapt"]
		info_diet.text = info["diet"]
		info_behavior.text = info["behavior"]
	else:
		details_box.hide()
		info_story.text = "YOU HAVE NOT DISCOVERED THIS CREATURE"
