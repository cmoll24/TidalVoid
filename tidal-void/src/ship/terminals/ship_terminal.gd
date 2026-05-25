extends StaticBody2D
class_name ShipTerminal

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@onready var interact_source : InteractSource= $InteractSource

func _ready() -> void:
	interact_source.on_interacted.connect(on_player_interact)
	interact_source.update_highlight.connect(set_highlight)

func on_player_interact() -> void:
	print("terminal interacted with")

func set_highlight(on : bool):
	if on:
		animated_sprite.play("outlined")
	else:
		animated_sprite.play("default")
