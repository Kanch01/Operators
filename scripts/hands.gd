extends Control
class_name InventoryUI

@onready var sfx = $".".get_node("/root/Run/SFX")
@onready var permas: Control = $Permas

var inventory: Inventory
signal number_chosen(num: int)

func _ready():
	if inventory == null:
		inventory = Inventory.new()
		add_child(inventory)
		
	inventory.draw_hand()
	draw_hand()
	draw_permas()
	
	for child: Button in permas.get_children():
		child.pressed.connect(send_perma.bind(child))
	
func draw_permas():
	for i in range(Gamestate.perma_numbers.size()):
		permas.get_child(i).text = str(Gamestate.perma_numbers[i])
		permas.get_child(i).visible = true
		permas.get_child(i).disabled = false
	
func draw_hand():
	var i: int = 0
	for button: Button in $dp/handgrid.get_children():
		if i < inventory.hand.size():
			button.text = str(inventory.hand[i])
			button.visible = true
			button.disabled = true
			if button.is_connected("pressed", _send_to_tray):
				button.pressed.disconnect(_send_to_tray)
			button.pressed.connect(_send_to_tray.bind(button))
		i += 1
		
func enable_buttons():
	for button: Button in $dp/handgrid.get_children():
		button.disabled = false
	for button: Button in permas.get_children():
		button.disabled = false
		
func disable_buttons():
	for button: Button in $dp/handgrid.get_children():
		button.disabled = true
	for button: Button in permas.get_children():
		button.disabled = true
		
func _send_to_tray(but: Button):
	sfx.play()
	inventory.use_number(int(but.text))
	$dp/handgrid.move_child(but, -1)
	emit_signal("number_chosen", int(but.text))
	but.visible = false
	but.disabled = true
	but.text = ""
	
func send_perma(but: Button):
	emit_signal("number_chosen", int(but.text))
		
