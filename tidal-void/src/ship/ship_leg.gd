@tool
extends Node2D
class_name ShipLeg

@onready var top_segment : Sprite2D = $TopSegment
@onready var bottom_segment : Sprite2D = $BottomSegment
@onready var foot : Sprite2D = $Foot
@onready var knee_cap : Sprite2D = $KneeCap

#The target location for the tip of the foot to be placed
@export var target : Marker2D
#The object that it is holding
@export var bubble : Node2D

@export var top_segment_length : int = 150
@export var bottom_segment_length : int =  300
#@export var foot_length : int = 64

@export var flipped = false
@export var behind = false

var knee_position : Vector2 = Vector2.ZERO
var foot_position : Vector2 = Vector2.ZERO

func _ready() -> void:
	if flipped:
		top_segment.scale.x *= -1
		bottom_segment.scale.x *= -1
		foot.scale.x *= -1
		knee_cap.scale.x *= -1
	
	if behind:
		knee_cap.scale.x *= -1
		knee_cap.z_index -= 1
		modulate = Color(0.6, 0.6, 0.6)

func _process(_delta: float) -> void:
	if not target:
		return
	
	solve_inverse_kinematics()

func solve_inverse_kinematics() -> void:
	var l1 : float = top_segment_length
	var l2 : float = bottom_segment_length
	
	var bend_sign : int = 1 if not flipped else -1
	
	var target_local : Vector2 = to_local(target.global_position)
	
	var dist : float = target_local.length()
	
	var min_reach : float = l1 - l2
	var max_reach : float = l1 + l2
	dist = clampf(dist, min_reach, max_reach)
	
	var dir : Vector2 = target_local.normalized()
	var clamped_target := dir * dist
	
	var target_angle = dir.angle()
	
	#Find angles and positions
	
	var top_segment_angle = target_angle - bend_sign * get_angle_of_C(l1, dist, l2)
	
	knee_position = l1 * Vector2.from_angle(top_segment_angle)
	
	var bottom_vec = clamped_target - knee_position
	
	var bottom_segment_angle = bottom_vec.angle()
	
	foot_position = knee_position + l2 * Vector2.from_angle(bottom_segment_angle)
	
	#Set properties
	
	top_segment.rotation = top_segment_angle - (PI/2)
	
	bottom_segment.rotation = bottom_segment_angle - (PI/2)
	bottom_segment.position = knee_position
	
	var knee_cap_angle : float
	if behind:
		knee_cap_angle = top_segment_angle + bend_sign * 0.8
	else:
		knee_cap_angle = top_segment_angle + bend_sign * 0.5
	
	var middle_angle = 0.5 * (top_segment_angle + bottom_segment_angle)
	
	if bend_sign * angle_difference(middle_angle, knee_cap_angle) > 0:
		knee_cap_angle = middle_angle
	
	knee_cap.rotation = knee_cap_angle - (PI/2)
	knee_cap.position = knee_position
	
	foot.position = foot_position
	
	var bubble_vec = foot_position - to_local(bubble.global_position)
	var foot_angle = bubble_vec.angle() if not flipped else bubble_vec.angle() + PI
	foot.rotation = (foot_angle + bend_sign * 0.31)

func get_angle_of_C(la : float, lb : float, lc : float):
	# Law of cosines - to find a missing angle
	# cos(C) = (a^2 + b^2 - c^2) / (2ab)
	
	var cos_c = (la ** 2 + lb ** 2 - lc ** 2) / (2 * la * lb)
	
	return acos(cos_c)
	
	
	
