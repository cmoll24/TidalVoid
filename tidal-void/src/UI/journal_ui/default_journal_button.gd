extends Button
@onready var default_info = load("res://src/UI/journal_ui/default_info_screen.tscn")


var creature_dict : Dictionary

func _on_pressed():
	#print("Entered Func")
	for node in get_tree().get_nodes_in_group("journal_info"):
		#print("Deleting")
		node.queue_free()
	
	# Create new info screen
	var new_info = default_info.instantiate()
	get_tree().current_scene.add_child(new_info)
	new_info.set_info(creature_dict)
	
	# Get the color rect of the info screen
	#var info_rect = new_info.get_node("InfoRect")
	
	# Grab the title, story, and picture nodes
	#var info_title = info_rect.get_node("creature_name")
	#var info_story = info_rect.get_node("creature_story")
	#var info_picture = info_rect.get_node("creature_image")

	# Grab the nodes of the other rich text labels
	#var title_adapt = info_rect.get_node("adaptation_title")
	#var info_adapt = info_rect.get_node("adaptation_info")
	#var title_diet = info_rect.get_node("diet_title")
	#var info_diet = info_rect.get_node("diet_info")
	#var title_behavior = info_rect.get_node("behavior_title")
	#var info_behavior = info_rect.get_node("behavior_info")
	
	# DEBUG
	#print(creature_dict["name"])
	
	# Change text for creature story and name
	# Also add the picture
	#info_title.text = creature_dict["name"]
	#info_story.text = creature_dict["story"]
	#info_picture.texture = load(creature_dict["asset"])
	#
	# Change the text of adapt section
	#info_adapt.text = creature_dict["adapt"]
	
	# Change the position of adapt info
	#info_adapt.position.y = title_adapt.position.y + 95
	
	# Change the position of diet title
	#title_diet.position.y = info_adapt.position.y + info_adapt.get_content_height() + 100
	# DEBUG
	#print("Info Adapt Height: ", info_adapt.get_content_height())
	#print("Diet Title Pos: ", title_diet.position.y)
	
	# Change the position of diet info
	#info_diet.position.y = title_diet.position.y + 95
	
	# Change the text in diet info
	#info_diet.text = creature_dict["diet"]
	
	# Change the position of behavior title
	#title_behavior.position.y = info_diet.position.y + info_diet.get_content_height() + 100
	# DEBUG
	#print("Info Diet Height: ", info_diet.get_content_height())
	#print("Behavior Title Pos: ", title_behavior.position.y)
	
	# Change the position position of behavior info
	#info_behavior.position.y = title_behavior.position.y + 95
	
	# Change the text in behavior info
	#info_behavior.text = creature_dict["behavior"]

	# Change the minimum size of the color rect
	#info_rect.custom_minimum_size.y = info_behavior.position.y + 300	
	
	# Add the child to the scene
