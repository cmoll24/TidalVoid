extends Node

@onready var parent : Node2D

@export var can_interact : bool = true;

@export var is_interacting : bool = false;

var on_interacted : Signal
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent();

func interact() -> bool:
	on_interacted.emit()
	is_interacting = !is_interacting
	return is_interacting;
	
