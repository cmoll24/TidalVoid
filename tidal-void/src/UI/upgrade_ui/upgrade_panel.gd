extends VBoxContainer

@export var slot_scene: PackedScene
@export var upgrade_items: Array[upgrade_store_item] = []

func _ready() -> void:
	print("UpgradePanel: upgrade_items count = ", upgrade_items.size())
	for item in upgrade_items:
		var slot = slot_scene.instantiate()
		add_child(slot)
		slot.set_store_item(item)
