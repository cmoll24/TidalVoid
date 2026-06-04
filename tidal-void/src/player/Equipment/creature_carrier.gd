extends PlayerPawn
class_name CreatureCarrier

@onready var player_sprite : Sprite2D = $PlayerSprite

@onready var head_lights : PointLight2D = $HeadLights

@onready var planet_thrust_particles : ThrustParticles = $ThrustParticles2

@onready var fuel_bar : TextureRect = $FuelContainer/FuelBar

@onready var interact_source : InteractSource = $InteractSource

@onready var disembark_marker : Marker2D = $DisembarkMarker

#ship_clearance is the length of vehicle
@export var vehicle_clearance : float = 160.0

@onready var bubble : Bubble = $Bubble

### instantaneous velocity change to creatures in the carrier when the bubble is deactivated
@export var bubble_push : float = 25

####fuel consumption per second of fuel usage(thrust)
@export var fuel_consumption_per_second : float = 0;

### the max fuel that can be held at once
@export var max_fuel : float = 100;

var fuel : float = 100;

var min_distance_line : Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	player_sprite.visible = false
	head_lights.enabled = false
	fuel = max_fuel
	health_comp.on_take_damage.connect(on_take_damage)
	
	call_deferred("after_ready")

func after_ready() -> void:
	var line : Line2D = Line2D.new()
	line.width = 10.0
	line.default_color = Color(0.584, 0.291, 0.71, 0.1)
	get_parent().add_child.call_deferred(line)
	min_distance_line = line

func set_thrust(direction : Vector2, multiplier : float = 1.0) -> void:
	if(fuel <= 0):
		#can't thrust if we run out
		thrust_direction = Vector2.ZERO
		thrust_particles.stop_thrust()
		return
	#Thruster behavior when off of the ground
	if direction != Vector2.ZERO:
		super.set_thrust(Vector2.from_angle(global_rotation), multiplier)
		target_rotation = direction.angle();
		thrust_particles.start_thrust(Vector2.from_angle(rotation), velocity, thrust_power)
	else:
		super.set_thrust(Vector2.ZERO, multiplier)
		thrust_particles.stop_thrust()
		
func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	#Increment fuel
	if thrust_direction != Vector2.ZERO:
		set_fuel(fuel - fuel_consumption_per_second * _delta)
	##check for dismount
	if controller and Input.is_action_just_pressed("jump"):
		eject_player()
	
	if dominant_body:
		## ensure we cannot get too close to a planet so as to be unable to leave
		var dist_sq : float = global_position.distance_squared_to(dominant_body.global_position)
		var thrust_output = thrust_power * thrust_multiplier * 0.8 #little wiggle room
		
		#The closest distance that the vehicle can be to any planet
		var minimum_clearance_dist : float = vehicle_clearance + dominant_body.collision_radius
		
		if dominant_body is Ship:
			minimum_clearance_dist += dominant_body.inside_ship_radius
		
		var push_back_radius = max(sqrt(dominant_body.mass / thrust_output), minimum_clearance_dist)
		draw_planet_pushback(dominant_body.global_position, push_back_radius)
		
		if ((dominant_body.mass / dist_sq) > thrust_output) or (dist_sq < minimum_clearance_dist**2):
			## if we are too close, push back to the edge
			var dir :Vector2 = (global_position-dominant_body.global_position).normalized()
			var min_dist = max(sqrt(dominant_body.mass/thrust_output), minimum_clearance_dist)
			
			global_position = dominant_body.global_position + dir * min_dist
			
			#Cancel inward radial velocity
			var radial_speed = velocity.dot(-dir)
			if radial_speed > 0:
				planet_thrust_particles.start_thrust(dir, velocity, 40)
				velocity += 1.1 * dir * radial_speed
		else:
			planet_thrust_particles.stop_thrust()
			
	### apply velocity colors
	update_traj_color.emit(lerp(Color.BLUE, Color.AQUA,velocity.length_squared()/122500))

func draw_planet_pushback(center : Vector2, radius : float):
	if not min_distance_line:
		return
	if not controller:
		min_distance_line.points = []
		return
	
	var points: PackedVector2Array = []
	
	var resolution = 128

	for i in resolution + 1:
		var angle = (float(i) / resolution) * TAU
		points.append(center + Vector2.from_angle(angle) * radius)

	min_distance_line.points = points

func eject_player():
	if(!controller):
		return #only execute if we are being controlled
	#if we jump, dismount and switch to the player
	var spawn_pos : Vector2 = disembark_marker.global_position
	#spawn the player
	var player_scene  = preload("res://src/player/player.tscn")
	var player : PlayerPawn = player_scene.instantiate()
	get_tree().get_root().add_child(player)
	player.global_position = spawn_pos
	#possess the player
	controller.call_deferred('possess_pawn', player, velocity)

func set_fuel(new_fuel : float):
	fuel = new_fuel
	fuel_bar.scale.x = fuel/max_fuel	
		
func start_possess(player_controller : PlayerController, previous_pawn_velocity : Vector2) -> void:
	super.start_possess(player_controller, previous_pawn_velocity)
	player_sprite.visible = true
	head_lights.enabled = true
	
func stop_possess(player_controller : PlayerController) -> void:
	super.stop_possess(player_controller)
	player_sprite.visible = false
	head_lights.enabled = false
	
func action_use(pressed : bool) -> void:
	if(!pressed):
		return
	bubble.toggle_bubble()
	
	#upon disabling the bubble, push all creatures in it away from the vehicle
	if(!bubble.b_bubble_enabled):
		var space_state = get_world_2d().direct_space_state
		
		var params : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
		params.shape = bubble.CollisionShape.shape
		params.transform = transform
		params.collision_mask = 2
		
		var results : Array[Dictionary] = space_state.intersect_shape(params,16)
		
		for result in results:
			var collider = result["collider"]
			if(collider is Creature):
				collider.velocity += Vector2.from_angle(global_rotation)*bubble_push

func on_take_damage(damage : float, dmg_type : HealthComponent.e_dmg_types, damage_causer : Node2D = null, instigator : Node = null):
	super.on_take_damage(damage, dmg_type, damage_causer, instigator)
	match dmg_type:
		#eject the player when grabbed
		HealthComponent.e_dmg_types.grab:
			eject_player()
			#temporarily disable the interact source so the player cannot get back in easily
			interact_source.disable_source()
			get_tree().create_timer(damage).timeout.connect(interact_source.enable_source)
		_:
			pass
