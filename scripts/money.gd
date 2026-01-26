extends Control

@onready var label: Label = $Label

var actual_money : int = Gamestate.muns
var display_money : int = 0

var _tween: Tween

const MIN_DURATION := 0.5
const MAX_DURATION := 1.5

signal done

func _ready():
	display_money = actual_money
	label.text = str(actual_money)
	
	
func set_money(amount: int):
	actual_money = amount
	display_money = float(amount)
	_update_label(amount)
	
func add_money(amount: int):
	if amount == 0:
		return

	actual_money += amount
	Gamestate.muns = actual_money
	_animate_to(float(actual_money))
	
func _animate_to(target_value: float):
	if _tween and _tween.is_running():
		_tween.kill()
	
	var start_value := display_money
	var delta = abs(target_value - start_value)
	if delta <= 0.0:
		_update_label(int(round(target_value)))
		return
	
	var total_duration = clamp(0.3 + sqrt(delta) * 0.03, MIN_DURATION, MAX_DURATION)
	
	_tween = create_tween()
	_tween.tween_method(Callable(self, "_set_display_money"), start_value, target_value, total_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(Callable(self, "_snap_to_actual"))

func _set_display_money(v: float) -> void:
	display_money = v
	_update_label(int(round(v)))

func _snap_to_actual() -> void:
	display_money = float(actual_money)
	_update_label(actual_money)

func _update_label(value: int) -> void:
	label.text = str(value)
	emit_signal("done")
