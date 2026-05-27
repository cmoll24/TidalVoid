extends Button
class_name JournalButton
@onready var default_info = load("res://src/UI/journal_ui/default_info_screen.tscn")


var creature_dict : Dictionary

var info_panel : PanelContainer

func set_info_panel_ref(panel : PanelContainer):
	info_panel = panel

func _on_pressed():
	#print("Entered Func")
	for node in get_tree().get_nodes_in_group("journal_info"):
		#print("Deleting")
		node.queue_free()
	
	# Create new info screen
	var new_info = default_info.instantiate()
	info_panel.add_child(new_info)
	new_info.set_info(creature_dict)
