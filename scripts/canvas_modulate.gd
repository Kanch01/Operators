extends CanvasModulate

@export var desat_duration: float = 0.7
@export var desat_gray: Color = Color(0.78, 0.00, 0.06, 0.5)

@export var slowmo_duration: float = 0.7
@export var slowmo_factor: float = 0.75

func pulse_desaturation(duration: float = desat_duration, gray: Color = desat_gray) -> void:
	# Tween the ‘color’ property of this CanvasModulate
	var tween = create_tween()
	tween.tween_property(self, "color", gray, duration * 0.3)
	tween.tween_property(self, "color", Color(1, 1, 1, 1), duration * 0.7).set_delay(duration * 0.3)

func slow_mo(duration: float = slowmo_duration, factor: float = slowmo_factor) -> void:
	# Tween the global time_scale
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", factor, 0.05)
	tween.tween_property(Engine, "time_scale", 1.0, duration - 0.05).set_delay(0.05)
