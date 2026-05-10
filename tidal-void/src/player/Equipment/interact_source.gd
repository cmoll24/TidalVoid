extends Node2D
class_name InteractSource

var parent : Node2D

@onready var interact_sprite : Sprite2D = $Sprite2D

@export var b_lock_interact_sprite_rotation : bool = false 

var sprite_scale : float = 0

var on_interacted : Signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent();
	sprite_scale = interact_sprite.scale.x
	interact_sprite.visible = false

func interact():
	on_interacted.emit()
	
###enables the interact sprite and turns it to face dir
func enable_interact_sprite(dir : Vector2) -> void:
	interact_sprite.visible = true
	global_rotation = dir.angle()+PI/2
	if(b_lock_interact_sprite_rotation):
		interact_sprite.rotation = -global_rotation

func disable_interact_sprite() -> void:
	interact_sprite.visible = false
	
### enables or disables "highlight", for when this interact source is the dominant one for the player
func set_highlight(on : bool):
	var new_scale : float
	if(on):
		new_scale = sprite_scale*1.5
	else:
		new_scale = sprite_scale
	interact_sprite.scale = Vector2(new_scale,new_scale)
	
