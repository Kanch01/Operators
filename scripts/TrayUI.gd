extends Control
class_name TrayUI

var inventory: Inventory
@onready var invui = get_parent().get_node("InventoryUI")
signal expression_submitted(result: float)
var tokens = []

func _ready():
	for button in $OpExpressions/Operators.get_children():
		button.connect("pressed", Callable(self, "_on_op_pressed").bind(button.text))
		
	invui.number_chosen.connect(self._on_number_added)
	$OpExpressions/EditButtons/Submit.pressed.connect(_on_submit_pressed)
	$OpExpressions/EditButtons/Delete.pressed.connect(_on_delete_pressed)
	$OpExpressions/EditButtons/Clear.pressed.connect(_on_clear_pressed)

func _on_number_added(num: int):
	if $OpExpressions/ResultLabel.text != "":
		_update_expression_label()
		$OpExpressions/ResultLabel.text = ""
	tokens.append(num)
	invui.refresh_hand()
	_update_expression_label()
	
func _on_op_pressed(op):
	tokens.append(op)
	_update_expression_label()
	
func _update_expression_label():
	var fullexpr := ""
	for token in tokens:
		fullexpr += str(token)
	$OpExpressions/Expressions.text = fullexpr
	
func _on_submit_pressed():
	var expr = Expression.new()
	var exprstr = $OpExpressions/Expressions.text
	if expr.parse(exprstr) == OK:
		var result = expr.execute()
		$OpExpressions/ResultLabel.text = str(result)
		emit_signal("expression_submitted", result)
	else:
		$OpExpressions/ResultLabel.text = "nya:3"
	inventory.after_draws()
	invui.refresh_hand()
	tokens = []
	
func _on_clear_pressed():
	if tokens.size() == 0:
		return
	for i in range(tokens.size()):
		var instance = tokens.pop_back()
		if typeof(instance) == TYPE_INT:
			inventory.return_number(int(instance))
			invui.refresh_hand()
	$OpExpressions/Expressions.text = ""
	
func _on_delete_pressed():
	if tokens.size() == 0:
		return
	var last = tokens.pop_back()
	if typeof(last) == TYPE_INT:
		inventory.return_number(int(last))
		invui.refresh_hand()
	_update_expression_label()
