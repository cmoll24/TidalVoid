class_name Ship
extends Planet

@onready var ship_exterior = $ShipTextureExterior

@onready var player_detector = $PlayerDetector

@export var inside_ship_radius : float = 182


func _ready() -> void:
	super._ready()
	show_exterior()

func show_exterior():
	ship_exterior.show()

func hide_exterior():
	ship_exterior.hide()

func _process(delta: float) -> void:
	#We need this so that the area2d can collide with static bodies
	player_detector.rotate(0) #rotate by nothing to trick it into thinking it is moving

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hide_exterior()

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		show_exterior()
