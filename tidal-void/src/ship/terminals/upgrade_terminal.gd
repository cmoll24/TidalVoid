extends ShipTerminal

@export var upgrade_menu_scene: PackedScene

var _menu: UIMenu = null

func on_player_interact() -> void:
	if _menu == null:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "UpgradeMenuLayer"
		canvas_layer.layer = 10
		add_child(canvas_layer)

		_menu = upgrade_menu_scene.instantiate()
		_menu.name = "UpgradeMenu"
		canvas_layer.add_child(_menu)

	_menu.call_deferred("open_menu")
