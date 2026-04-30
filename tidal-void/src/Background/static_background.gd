extends TextureRect
#This script is to make the star background appear static when the camera zooms and rotates

var camera_parent : ZoomCamera

func _ready() -> void:
	camera_parent = get_parent()
	
	set_inital_size()

func set_inital_size():
	var viewport_size = get_viewport_rect().size
	var current_zoom = camera_parent.min_zoom
	
	# when zoom decreases the visible area grows inversely
	var needed_size = viewport_size / current_zoom
	
	# add padding so rotation never reveals edges
	var diagonal = needed_size.length()
	var padded = Vector2(diagonal, diagonal)
	
	size = padded
	pivot_offset = padded / 2.0
	position = -padded / 2.0

func _process(_delta: float) -> void:
	rotation = -camera_parent.rotation
	
	if camera_parent.zoom.x < 0.3:
		visible = false
	else:
		visible = true
