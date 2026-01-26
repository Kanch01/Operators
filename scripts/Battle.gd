extends Node2D

var inventory: Inventory
@onready var ui_inventory = $InventoryUI
@onready var ui_tray = $TrayUI
var currenemy: Character = null
@onready var player: Character = $Player

func _ready():
	currenemy = $Enemy
	inventory = Inventory.new()
	add_child(inventory)
	
	ui_inventory.inventory = inventory
	ui_tray.inventory = inventory
	
	inventory.draw_hand()
	ui_tray.connect("expression_submitted", Callable(self, "_damaged"))
	
func _damaged(dmg):
	if currenemy:
		currenemy.damaged(dmg)
		if currenemy.health > 0:
			player.damaged(10)
		
	

	
