@tool
extends TextureRect

#set mass to make the pull radius circle display the right size
@export var mass : float:
	set(value):
		mass = value
		var pull_radius : float = sqrt((mass*1000) / negligible_threshold)
		scale = Vector2(pull_radius, pull_radius) / (size / 2)#because scale is diameter
		position = -Vector2(pull_radius, pull_radius)#/ 2.0

@export var negligible_threshold = 10
