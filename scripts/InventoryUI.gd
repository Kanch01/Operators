extends Control
class_name inde
const HandSlotScene = preload("res://scenes/HandSlot.tscn")

# const MAX_SLOTS: int = 9
var inventory: Inventory
signal number_chosen(num: int)
var slots: Array = []

func _ready():
	if inventory == null:
		inventory = Inventory.new()
		add_child(inventory)
	inventory.draw_hand()
	refresh_hand()

func _clear_hand_grid():
	for child in $HandGrid.get_children():
		child.queue_free()

func refresh_hand():
	_clear_hand_grid()
	for i in range(9):
		var slot: HandSlot = HandSlotScene.instantiate()
		$HandGrid.add_child(slot)
		if i < inventory.hand.size():
			slot.number = inventory.hand[i]
			slot.text = str(slot.number)
			slot.disabled = false
		else:
			$HandGrid.remove_child(slot)
		slot.connect("number_chosen", Callable(self, "_on_slot_chosen"))
		
func _on_slot_chosen(num: int):
	inventory.use_number(num)
	refresh_hand()
	emit_signal("number_chosen", num)

# func _on_submit_pressed():
	# inventory.draw_hand()
	# refresh_hand()
	
