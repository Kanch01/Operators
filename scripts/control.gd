extends Control

@onready var clicker: Button = $Button
@onready var timer: Timer = $Timer

var _pending_single := false

func _ready():
	clicker.gui_input.connect(check)
	
func check(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if event.double_click:
			# Second click arrived in time: cancel pending single and fire double.
			_pending_single = false
			_on_double_click()
		else:
			# First click: start a short timer to see if another click comes in.
			if not _pending_single:
				_pending_single = true
				_start_single_click_wait()
				
func _start_single_click_wait() -> void:
	timer.start()
	await timer.timeout
	# If no double click arrived during the window, commit the single click.
	if _pending_single:
		_pending_single = false
		_on_single_click()
		
func _on_double_click():
	print("has double")
	
func _on_single_click():
	print("has single")
