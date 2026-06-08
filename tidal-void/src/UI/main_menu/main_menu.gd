extends CanvasLayer
class_name MainMenu

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Maps/Tutorial/tutorial.tscn")


func _on_main_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/Maps/main_map.tscn")
