extends Node2D
class_name Plant

@onready var shake_area: Area2D = $ShakeArea

@onready var sprite: Sprite2D = $Sprite2D

@onready var anim_player : AnimationPlayer = $Sprite2D/AnimationPlayer

@export var on_touch_shake_amount : float = 0.05

var sprite_material : ShaderMaterial

var elapsed_time : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_material = sprite.material
	sprite_material.set_shader_parameter("shake_amount",on_touch_shake_amount) 
	
	
func _physics_process(_delta: float) -> void:
	#I am forced to use static bodies due to engine limitations which in turn means static area2D's cannot detect them
	shake_area.rotate(0) #rotate by nothing to trick it into thinking it is moving
	
func _process(delta: float) -> void:
	#since godot is a terrible engine, I also have to manually feed time into my shader because I have no way to get the gobal shader time
	elapsed_time += delta #I have to use a manual variable for this because get_shader_parameter always returns nil
	if(elapsed_time <= 10.0):
		sprite_material.set_shader_parameter("elapsed_time",elapsed_time +delta)
	
	
### make sure to connect this in scene
func _on_shake_area_body_entered(body: Node2D) -> void:
	#use the shader to make a little shake effect if a drift body collides
	if(body is DriftBody):
		var left = (body.global_position - global_position).dot(global_transform.basis_xform(Vector2.RIGHT)) > 0
		sprite_material.set_shader_parameter("shake_left", left)
		sprite_material.set_shader_parameter("elapsed_time",0)
		elapsed_time = 0
		
		 
