extends BaseInventory
class_name PlayerInventory

#inherits all functionality from BaseInventoryContainer

func _ready() -> void:
	inventory_size = 20  #Player has 20 slots
	super._ready()
