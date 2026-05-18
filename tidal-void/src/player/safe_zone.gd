extends Area2D

@export var max_time : float = 10.0
@export var refill_speed : float = 1.0
@export var drain_speed : float = 1.0

var current_time : float
var player_inside : bool = false
var player_dead : bool = false

@onready var darkness : CanvasModulate = $CanvasModulate
@onready var debug_label : Label = $Label

func _ready():
	current_time = max_time
	darkness.color = Color(0.2,0.2,0.2)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _physics_process(delta):
	debug_label.text = str(snapped(current_time, 0.01))
	# Once timer hits zero, never refill again
	if !player_dead:
		
		if player_inside:
			current_time += refill_speed * delta
		else:
			current_time -= drain_speed * delta
		
		current_time = clamp(current_time, 0.0, max_time)
		
		update_darkness()
		
		if current_time <= 0:
			player_dead = true
			kill_player()

func update_darkness():

	# 1 = full timer
	# 0 = dead
	var percent := current_time / max_time

	# White when safe, black when dying
	var brightness = clamp(percent, 0.0, 1.0)

	darkness.color = Color(
		brightness,
		brightness,
		brightness,
		1.0
	)

func kill_player() -> void:

	await get_tree().create_timer(1.0).timeout
	
	if GV.player_node:
		GV.player_node.die()

func _on_area_entered(area):

	if area.get_parent() is Player:
		player_inside = true

func _on_area_exited(area):

	if area.get_parent() is Player:
		player_inside = false
		
func reset_timer():
	current_time = max_time
	player_dead = false
	update_darkness()
