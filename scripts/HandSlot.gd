extends Button
class_name HandSlot
@export var number: int = 0

signal number_chosen(num: int)
	
func _pressed():
	if not disabled:
		emit_signal("number_chosen", number)
		print("pressed")
