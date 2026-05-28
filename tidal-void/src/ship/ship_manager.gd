extends Node2D
class_name ShipManager

#marker for the vehicle spawn location
@onready var vehicle_spawn_location : Node2D = $VehicleSpawnMarker


func spawn_vehicle(instance_path : String):
	var vehicle : DriftBody = load(instance_path).instantiate()
	vehicle.global_position = vehicle_spawn_location.global_position
	get_tree().root.add_child(vehicle)
