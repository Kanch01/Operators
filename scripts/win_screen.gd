extends Control

@onready var muns = $Screen/Money
@onready var button: Button = $Screen/Button
@onready var aniplayer: AnimationPlayer = $BNAni


var e_diff: String = Gamestate.ediff

func _ready():
	increase_muns()
	button.pressed.connect(nextin)
	muns.connect("done", display_next)
	
func increase_muns():
	var added_muns = 0
	if e_diff ==  "low":
		added_muns = 300
	elif e_diff == "mid":
		added_muns = 500
	else:
		added_muns = 700
		
	if Gamestate.extra_muns:
		added_muns += 350
		
	muns.add_money(added_muns)
	
func display_next():
	button.visible = true
	aniplayer.play("button")

func nextin():
	var next = get_tree().root
	next.get_node("Run").show_scene("map")
