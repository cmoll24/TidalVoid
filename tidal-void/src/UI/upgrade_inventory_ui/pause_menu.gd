extends Control

# PauseMenu is the parent of both Inventory and UpgradeStore.
# It owns the pause/unpause logic and the I key toggle.

@onready var inventory = $Inventory
@onready var upgrade_store = $UpgradeStore
@onready var health_label = $"../HealthLable"

func _process(delta):
	health_label.text = str(GV.player_health) + " HP"

func _ready():
	# hides at start
	hide()
	# if we open it, inventory needs to show first, then upgrade_store
	inventory.show()
	upgrade_store.hide()

func _input(event):
	if event.is_action_pressed("inventory"):
		# if the menu is already visible, then closes it.
		if visible:
			close_pause_menu()
		else:
			open_pause_menu()

func open_pause_menu():
	inventory.show()
	upgrade_store.hide()
	#show() to show the pause menu itself
	show()
	get_tree().paused = true

func close_pause_menu():
	hide()
	get_tree().paused = false

#Called by Inventorys upgrade
func show_upgrade_store():
	inventory.hide()
	upgrade_store.show()

#Called by UpgradeStores back
func show_inventory():
	upgrade_store.hide()
	inventory.show()
