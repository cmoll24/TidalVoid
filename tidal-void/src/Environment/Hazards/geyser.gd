extends Node2D
class_name Geyser

@onready var spray_timer : Timer = $SprayTimer

@onready var damage_area : Area2D = $DamageArea 

@onready var geyser_particles : CPUParticles2D = $GeyserParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spray_timer.timeout.connect(spray_geyser)

func spray_geyser():
	#play the particle and enable the collision
	geyser_particles.emitting = true
	get_tree().create_timer(0.1).timeout.connect(enable_geyser_collision)
	get_tree().create_timer(1.1).timeout.connect(disable_geyser_collision)
	
func enable_geyser_collision():
	damage_area.monitoring = true
	damage_area.monitorable = true
	
func disable_geyser_collision():
	damage_area.monitoring = false
	damage_area.monitorable = false
	
func _physics_process(delta: float) -> void:
	if(damage_area.monitoring):
		damage_area.rotate(0)
		
func on_body_collide(body : Node2D):
	if(body.has_method('die')):
		body.die()
