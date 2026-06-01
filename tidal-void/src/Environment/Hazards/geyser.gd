extends Node2D
class_name Geyser

#heat damage to deal to colliding object(celsius)
@export var geyser_heat = 100

#knockback damage on colliding with geyser
@export var geyser_knockback : float = 25

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
	#if the geyser is active...
	if(damage_area.monitoring):
		#Fake rotation to work around godot collision bug
		damage_area.rotate(0)
		#damage anything colliding
		for body in damage_area.get_overlapping_bodies():
			#get the health component if there is one
			var hc : HealthComponent = body.get_node_or_null("HealthComponent")
			if(hc):
				#if we have a valid health component, deal heat damage
				hc.take_damage(geyser_heat,HealthComponent.e_dmg_types.heat,self)
				hc.take_damage(geyser_heat,HealthComponent.e_dmg_types.knockback,self)
