extends Node2D

@onready var fps_label = $CanvasLayer/FPSLabel

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second()) + " fps"
