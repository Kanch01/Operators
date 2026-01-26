extends Control
class_name Tray

# player inventory of numbers
var inventory: Inventory

# Tray tree items that are used in code
@onready var invui = get_parent().get_node("Hand")
@onready var sfx = $".".get_node("/root/Run/SFX")
@onready var mult = $Operators/Mult
@onready var timer: Timer = $Timer

@onready var operators: HBoxContainer = $Operators
@onready var submit: Button = $Rands/Submit
@onready var delete: Button = $Rands/Delete
@onready var clear: Button = $Rands/Clear

@onready var label: Label = $Result
@onready var expr_label: Label = $Expression


# signal given to battle script with equation result
signal expression_submitted(result: int)

# tokens of final equation, selected operands or operators go here
var tokens = []

# used to see if click is a double or single click
var _pending_single := false

# used to see if last token in expression is a number
# used to avoid a num proceeding a num
var has_two := false

func _ready():
	# connects all operators buttons to a pressed function
	for button in operators.get_children():
		button.connect("pressed", Callable(self, "_on_op_pressed").bind(button.tooltip_text))
		
	# connects hand signal of number added to tray
	invui.number_chosen.connect(_on_number_added)
	
	# connects tray actions
	submit.pressed.connect(_on_submit_pressed)
	delete.pressed.connect(_on_delete_pressed)
	clear.gui_input.connect(_on_clear_pressed)

func _on_number_added(num: int):
	# if previous if num, disable nums
	if has_two:
		invui.disable_buttons()
		
	mult.disabled = false
	if label.text != "":
		_update_expression_label()
		label.text = ""
	tokens.append(num)
	_update_expression_label()
	
	# used to check for akimbo ability
	if Gamestate.two_nums == false:
		invui.disable_buttons()
	else:
		if num != 1:
			invui.disable_buttons()
	if num == 1:
		has_two = true
	
# function used for when battle ends
func disable_submit():
	submit.disabled = true
	
# function used for adding operators
func _on_op_pressed(op):
	if Gamestate.exponentials == false:
		mult.disabled = true
	
	# checking for exception that * cannot proceed an operator
	if op == "(" or op == ")":
		mult.disabled = false
	sfx.play()
	tokens.append(op)
	_update_expression_label()
	invui.enable_buttons()
	has_two = false
	
# updates expression label
func clear_for_boss():
	for token in tokens:
		if typeof(token) == TYPE_INT:
			inventory.return_number(int(token))
	
	invui.draw_hand()
	tokens.clear()
	expr_label.text = ""
	has_two = false
	label.text = ""
	mult.disabled = false

func _update_expression_label():
	var fullexpr := ""
	for token in tokens:
		fullexpr += str(token)
	expr_label.text = fullexpr
	
func _on_submit_pressed():
	sfx.play()
	
	# parses and executes tokens in equation
	var expr = Expression.new()
	var exprstr = expr_label.text
	if expr.parse(exprstr) == OK:
		var result = expr.execute()
		label.text = str(result)
		emit_signal("expression_submitted", result)
	else:
		# temporary error text if equation isn't valid
		label.text = "nya:3"
	
	# draws from inventory, and displays new inventory UI
	inventory.after_draws()
	# invui.refresh_hand()
	invui.draw_hand()
	invui.enable_buttons()
	tokens = []
	expr_label.text = ""
	
# checks to see if clear was double or singley clicked
# double click check exists solely for Helping Hand ability
func _on_clear_pressed(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if event.double_click and Gamestate.double_clear:
			_pending_single = false
			_on_double_click()
		else:
			if not _pending_single:
				_pending_single = true
				_start_single_click_wait()
				
func _start_single_click_wait() -> void:
	timer.start()
	await timer.timeout
	if _pending_single:
		_pending_single = false
		_on_single_click()
		
# if double clicked, redraw hand
func _on_double_click():
	inventory.redraw()
	invui.draw_hand()
	invui.enable_buttons()
	
# if singley clicked, clear equation
func _on_single_click():
	sfx.play()
	has_two = false
	if tokens.size() == 0:
		return
	for i in range(tokens.size()):
		var instance = tokens.pop_back()
		
		# if token is a number, pop into hand
		if typeof(instance) == TYPE_INT:
			inventory.return_number(int(instance))
			invui.draw_hand()
			invui.enable_buttons()
	expr_label.text = ""
	
# function for delete pressed
func _on_delete_pressed():
	sfx.play()
	if tokens.size() == 0:
		return
	var last = tokens.pop_back()
	
	# if operator is deleted, enable multiplication
	if typeof(last) == TYPE_STRING:
		mult.disabled = false
		
	# if operand is deleted, return to hand
	if typeof(last) == TYPE_INT:
		inventory.return_number(int(last))
		has_two = false
		# invui.refresh_hand()
		invui.draw_hand()
		invui.enable_buttons()
	_update_expression_label()
	
	
