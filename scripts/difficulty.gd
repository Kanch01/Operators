extends Control

@onready var parent: TextureRect = $TextureRect
@onready var sfx = $".".get_node("/root/Run/SFX")

'''
var enemies = {
	"low": {"time": 0, "dmg": 0, "range": 0}, 
	"mid": {"time": 0, "dmg": 0, "range": 0}, 
	"high": {"time": 0, "dmg": 0, "range": 0}
}
'''

func _ready():
	
	for child: TextureButton in parent.get_children():
		child.mouse_entered.connect(_hovering.bind(child))
		child.mouse_exited.connect(_nhovering.bind(child))
		child.pressed.connect(_populate.bind(child))
		
func _hovering(but: TextureButton):
	but.modulate = Color(1, 1, 1, 1)

func _nhovering(but: TextureButton):
	but.modulate = Color(0.63, 0.63, 0.63, 1)
	
func _populate(but: TextureButton):
	sfx.play()
	if but.name == "Easy":
		Gamestate.enemies.get("low").set("time", 24)
		Gamestate.enemies.get("low").set("dmg", 3)
		Gamestate.enemies.get("low").set("range", [8, 20])
		Gamestate.enemies.get("mid").set("time", 16)
		Gamestate.enemies.get("mid").set("dmg", 4)
		Gamestate.enemies.get("mid").set("range", [22, 36])
		Gamestate.enemies.get("high").set("time", 10)
		Gamestate.enemies.get("high").set("dmg", 4)
		Gamestate.enemies.get("high").set("range", [38, 50])
		
		Gamestate.enemies.get("low").set("status_odds", 50)
		Gamestate.enemies.get("mid").set("status_odds", 40)
		Gamestate.enemies.get("high").set("status_odds", 30)
	elif but.name == "Normal":
		Gamestate.enemies.get("low").set("time", 20)
		Gamestate.enemies.get("low").set("dmg", 4)
		Gamestate.enemies.get("low").set("range", [10, 30])
		Gamestate.enemies.get("mid").set("time", 14)
		Gamestate.enemies.get("mid").set("dmg", 5)
		Gamestate.enemies.get("mid").set("range", [31, 50])
		Gamestate.enemies.get("high").set("time", 8)
		Gamestate.enemies.get("high").set("dmg", 6)
		Gamestate.enemies.get("high").set("range", [51, 80])
		
		Gamestate.enemies.get("low").set("status_odds", 25)
		Gamestate.enemies.get("mid").set("status_odds", 20)
		Gamestate.enemies.get("high").set("status_odds", 15)
	elif but.name == "Hard":
		Gamestate.enemies.get("low").set("time", 16)
		Gamestate.enemies.get("low").set("dmg", 5)
		Gamestate.enemies.get("low").set("range", [10, 30])
		Gamestate.enemies.get("mid").set("time", 11)
		Gamestate.enemies.get("mid").set("dmg", 6)
		Gamestate.enemies.get("mid").set("range", [31, 60])
		Gamestate.enemies.get("high").set("time", 6)
		Gamestate.enemies.get("high").set("dmg", 6)
		Gamestate.enemies.get("high").set("range", [61, 100])
		
		Gamestate.enemies.get("low").set("status_odds", 15)
		Gamestate.enemies.get("mid").set("status_odds", 13)
		Gamestate.enemies.get("high").set("status_odds", 10)
	else:
		Gamestate.enemies.get("low").set("time", 8)
		Gamestate.enemies.get("low").set("dmg", 5)
		Gamestate.enemies.get("low").set("range", [20, 40])
		Gamestate.enemies.get("mid").set("time", 5)
		Gamestate.enemies.get("mid").set("dmg", 5)
		Gamestate.enemies.get("mid").set("range", [60, 80])
		Gamestate.enemies.get("high").set("time", 3)
		Gamestate.enemies.get("high").set("dmg", 7)
		Gamestate.enemies.get("high").set("range", [100, 140])
		
		Gamestate.enemies.get("low").set("status_odds", 8)
		Gamestate.enemies.get("mid").set("status_odds", 7)
		Gamestate.enemies.get("high").set("status_odds", 6)
	
	Gamestate.difficulty = but.name
	var par = get_tree().root
	par.get_node("Run").show_scene("character_select")
	
