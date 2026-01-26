extends Control

@onready var parent = $TextureRect
@onready var sfx = $".".get_node("/root/Run/SFX")

func _ready():
	# shader_mat.set_shader_parameter("radius", shader_mat.get_shader_parameter("feather"))
	# shader_mat.set_shader_parameter("opacity", 1.0)
	
	for child: TextureButton in parent.get_children():
		child.mouse_entered.connect(_hovering.bind(child))
		child.mouse_exited.connect(_left.bind(child))
		
func _hovering(button: TextureButton):
	button.modulate = Color(1, 1, 1, 0.6) 

func _left(button: TextureButton):
	button.modulate = Color(1, 1, 1, 1) 

func _on_new_run_pressed() -> void:
	sfx.play()
	Gamestate.reset()
	var par = get_tree().root
	par.get_node("Run").show_scene("difficulty")
	
func _on_exit_pressed() -> void:
	sfx.play()
	get_tree().quit()
	
#func expand_blackout(duration: float = 1.0) -> void:
#	rectan.visible = true
#	var start_r = shader_mat.get_shader_parameter("feather")
#	shader_mat.set_shader_parameter("radius", start_r)
#	
#	var tw = create_tween()
#	tw.tween_property(shader_mat, "shader_parameter/radius", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
#	
#	await tw.finished
	
	
