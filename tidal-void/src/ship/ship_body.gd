class_name Ship
extends Planet

@onready var ship_exterior = $ShipTextureExterior
@onready var player_detector = $PlayerDetector
@export var inside_ship_radius : float = 182

@onready var storage_bubble : CreatureStorage = $CreatureStorage

var player_in_ship : bool = false

var bubble_close_pos_y : float = 240.0
var bubble_far_pos_y : float = 440.0

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
	
	var target_bubble_pos_y : float
	if player_in_ship:
		target_bubble_pos_y = bubble_close_pos_y
	else:
		target_bubble_pos_y = bubble_far_pos_y
	
	storage_bubble.position.y = lerpf(storage_bubble.position.y, target_bubble_pos_y, 0.2 * delta)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		hide_exterior()
		player_in_ship = true
		if body is Player:
			body.remove_helmet()

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		show_exterior()
		player_in_ship = false
		if body is Player:
			body.attach_helmet()
