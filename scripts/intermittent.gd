extends ColorRect
class_name Transition

@onready var shader_mat : ShaderMaterial = $".".material as ShaderMaterial
@onready var icon: Label = $Label
@onready var aniplayer: AnimationPlayer = $AnimationPlayer

signal next_one

# var texts = ["+", "-", "×", "÷"]

func _ready():
	# start with no blackout
	# var symb_int = randi_range(0, 3)
	# icon.text = texts[symb_int]
	#"""
	shader_mat.set_shader_parameter("radius", shader_mat.get_shader_parameter("feather"))
	shader_mat.set_shader_parameter("opacity", 1.0)
	#"""
	#shader_mat.set_shader_parameter("radius", 1.0)
	#shader_mat.set_shader_parameter("opacity", 1.0)
	#contract_blackout()
	
func full_transition(duration: float = 1.0):
	var start_r = shader_mat.get_shader_parameter("feather")
	shader_mat.set_shader_parameter("radius", start_r)
	
	var tw = create_tween()
	tw.tween_property(shader_mat, "shader_parameter/radius", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tw.finished
	
	var tw2 = create_tween()
	tw2.tween_property(shader_mat, "shader_parameter/radius", 0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tw2.finished
	$".".visible = false

	
func transition(dir: int):
	if dir == 0:
		shader_mat.set_shader_parameter("radius", shader_mat.get_shader_parameter("feather"))
		shader_mat.set_shader_parameter("opacity", 1.0)
		expand_blackout()
		aniplayer.play("spinning")
		
	else:
		shader_mat.set_shader_parameter("radius", 1.0)
		shader_mat.set_shader_parameter("opacity", 1.0)
		contract_blackout()
		aniplayer.play("spinning_rev")
	

func expand_blackout(duration: float = 1.0) -> void:
	aniplayer.play("spinning")
	var start_r = shader_mat.get_shader_parameter("feather")
	shader_mat.set_shader_parameter("radius", start_r)
	
	var tw = create_tween()
	tw.tween_property(shader_mat, "shader_parameter/radius", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tw.finished.connect(_done)

func contract_blackout(duration: float = 1.0) -> void:
	# var end_r = shader_mat.get_shader_parameter("feather")
	aniplayer.play("spinning_rev")
	var tw2 = create_tween()
	tw2.tween_property(shader_mat, "shader_parameter/radius", 0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await tw2.finished
	
	visible = false
	
	
func _done():
	emit_signal("next_one")
