extends StaticBody2D
class_name ShipTerminal

@onready var sprite = $Sprite2D

@onready var player_detector = $PlayerDetector

func on_player_interact(player : Player) -> void:
	pass
	

func _process(delta: float) -> void:
	player_detector.rotate(0)

func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.modulate = Color(0.8, 0.8, 0.0, 1.0)

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.modulate = Color.WHITE
