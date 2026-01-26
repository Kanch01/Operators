# CameraShake.gd
extends Camera2D

@export var default_duration: float = 0.3
@export var default_magnitude: float = 8.0

# internal state
var _time_left: float = 0.0
var _shake_mag:   float = 0.0
var _orig_pos:    Vector2

func _ready():
	# capture the camera’s resting position
	_orig_pos = position

func shake(duration: float = default_duration, magnitude: float = default_magnitude) -> void:
	"""
	Call this from your battle code:
		$Camera2D.shake(0.25, 12)
	"""
	_time_left = duration
	_shake_mag  = magnitude

func _process(delta: float) -> void:
	if _time_left > 0.0:
		_time_left -= delta
		# random offset in range [-_shake_mag, +_shake_mag]
		position = _orig_pos + Vector2(
			randf_range(-_shake_mag, _shake_mag),
			randf_range(-_shake_mag, _shake_mag)
		)
	else:
		# once time’s up, snap back (only if we actually moved)
		if position != _orig_pos:
			position = _orig_pos
