extends CanvasLayer
@onready var default_button = load("res://src/UI/journal_ui/default_journal_button.tscn")

func _ready() -> void:
	# For every creature in the dictionary
	for creature in GV.creature_button_dict:
		# Instatiate a new default button
		var new_button = default_button.instantiate()
		new_button.creature_dict = GV.creature_button_dict[creature]
		
		# Grab the creature data from the dictionary
		var creature_data = GV.creature_button_dict[creature]
		
		# Align the image of the button to middle
		new_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		new_button.custom_minimum_size = Vector2(423, 250)
		
		# Make sure image does not make button bigger
		new_button.expand_icon = true
		
		# Give button an image
		new_button.icon = load(creature_data["asset"])
		
		# Grab the VBoxContainer Node
		var container = get_node("ScrollContainer/VBoxContainer")
		
		# Add the new button to the VBoxContainer
		container.add_child(new_button)
