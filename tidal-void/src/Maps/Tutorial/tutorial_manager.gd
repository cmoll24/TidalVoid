extends OrbitTest
class_name TutorialManager

@export var camera_controls_msg : Label #0
@export var ground_mvmt_controls_msg : Label #1
@export var jump_controls_msg : Label #2
@export var space_controls_msg : Label #3
@export var prograde_controls_msg : Label #4
@export var interact_controls_msg : Label #5
@export var vehicles_msg : Label # 6
@export var capture_creature_msg : Label #7
@export var completion_msg : Label #8
@export var creature_carrier : Node
@export var bubble_area : Area2D

var stage : int = 0

var timing : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	ground_mvmt_controls_msg.visible = false #1
	jump_controls_msg.visible = false #2
	space_controls_msg.visible = false #3
	prograde_controls_msg.visible = false #4
	interact_controls_msg.visible = false #5
	vehicles_msg.visible = false # 6
	capture_creature_msg.visible = false #7
	completion_msg.visible = false #8


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	match stage:
		0:
			#Show the player the scroll controls until they zoom in
			if(Input.is_action_just_pressed("zoom_in")):
				stage += 1 # why no ++ :(
				camera_controls_msg.queue_free()
				ground_mvmt_controls_msg.visible = true
		1:
			#Show the player the move controls until they get to the other side of the planet
			if(GV.player_node.global_position.x > 450):
				stage+= 1
				ground_mvmt_controls_msg.queue_free()
				jump_controls_msg.visible = true;
		2:
			#Show the player the jump controls and they jump
			if(Input.is_action_just_released("jump")):
				stage+= 1
				jump_controls_msg.queue_free()
				space_controls_msg.visible = true;
				timing = 0
		3:
			#Show the player the space controls until they thrust for a second
			if(Input.is_action_pressed("thrust")):
				timing+=delta
				if(timing > 1):
					stage+= 1
					space_controls_msg.queue_free()
					prograde_controls_msg.visible = true;
					timing = 0
		4:
			#show the player the prograde controls until they land
			if(GV.player_node is Player):
				if(GV.player_node.walking_on_ground):
					timing += delta
			if(timing > 1):
				stage+= 1
				prograde_controls_msg.queue_free()
				interact_controls_msg.visible = true;
				timing = 0
		5:
			#show the player the interact controls until they throw something
			if(GV.player_node is Player):
				if(GV.player_node.held_creature):
					stage+= 1
					interact_controls_msg.queue_free()
					vehicles_msg.visible = true;
					creature_carrier.create_instance(true)
		6:
			#Show the player the vehicle controls until they enter and exit
			if(GV.player_node is CreatureCarrier):
				timing = 1
				capture_creature_msg.visible = true;
			elif(timing == 1 and GV.player_node is Player):
				stage+= 1
				vehicles_msg.queue_free()
		6,7:
			#Move the player to the main scene if they capture something
			bubble_area.rotate(0)
			for b in bubble_area.get_overlapping_bodies():
				if(b is Creature):
					stage = 8
					completion_msg.visible = true
					print("congradushulatons")
		8:
			pass
		_:
			print("stages broke on tutorial manager")
				
