extends Control
class_name Heal

func _ready():
	Gamestate.pstats.heal(20)
	await get_tree().create_timer(5.0).timeout
	move_on()
	
func move_on():
	var par = get_tree().root
	par.get_node("Run").show_scene("map")
