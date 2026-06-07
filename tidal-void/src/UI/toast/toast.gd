extends RichTextLabel
class_name Toast

#This is a bit of UI for showing the player information
#It appears on screen for a bit then disappears

@export var slide_duration: float = 0.5
@export var display_duraction : float = 2.0
@export var fade_duration: float = 0.5

func _ready() -> void:
	global_position.x = get_viewport_rect().size.x - size.x
	global_position.y = -size.y
	
	hide()

func display_text(new_text : String):
	text = new_text
	
	toast_animation()

func toast_animation():
	show()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position:y", 0.0, slide_duration)
	
	tween.tween_interval(display_duraction)
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	
	tween.tween_callback(die)

func die():
	queue_free()
