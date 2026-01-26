extends Control

@onready var parent: TextureRect = $Background
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var character_select = preload("res://scenes/characters.tscn")
@onready var next_button = $Button
@onready var aniplayer = $BNAni
@onready var sfx = $".".get_node("/root/Run/SFX")

# If one shot, time stops for 5 seconds (44)
# After every battle, regnerates 50% of max health (38)
# Every one in 6 enemy attacks is blocked (56)
# Defeating enemy within 7 seconds makes next enemy's attacks slower (50)

var CHARAS = {
	0: {"name": "Minuin", "vis": "res://assets/UI/cat.png", "HP": "44", "ability": "Eternal Clock", "text": "If in one shot range, time stops for 5 seconds"},
	1: {"name": "Additus", "vis": "res://assets/UI/axolotl.png", "HP": "38", "ability": "Rested Soul", "text": "After every battle, regenerates 50% of max health"},
	2: {"name": "Pif", "vis": "res://assets/UI/panda.png", "HP": "56", "ability": "Leisurely Parry", "text": "Every 1 in 6 enemy attacks are blocked"},
	3: {"name": "Tiburio", "vis": "res://assets/UI/tiger.png", "HP": "50", "ability": "Rapid Strike", "text": "Defeating enemy within 7 seconds makes next enemy's attacks slower"}
}

var plays: int = 0
var chare: String

func _ready():
	for child: TextureButton in parent.get_children():
		child.mouse_entered.connect(_hovering.bind(child))
		child.mouse_exited.connect(_nhovering.bind(child))
		child.pressed.connect(_populate.bind(child))
		
	next_button.pressed.connect(gonext)

func _populate(but: TextureButton):
	sfx.play()
	
	if parent.get_child_count() == 5:
		parent.get_children()[-1].queue_free()
	
	if plays == 0:
		ani.play()
		await ani.animation_finished
	
	var ind = but.get_meta("ind")
	var cscreen = character_select.instantiate()
	# cscreen.CHARAS.get(ind)
		
	var clips = cscreen.get_children()
	clips[0].texture = load(CHARAS.get(ind).get("vis"))
	clips[1].text = CHARAS.get(ind).get("name")
	clips[2].text = "HP " + CHARAS.get(ind).get("HP")
	clips[3].text = CHARAS.get(ind).get("ability") + "\n" + CHARAS.get(ind).get("text")
	parent.add_child(cscreen)
	plays = 1
	chare = but.name
	if not next_button.visible:
		next_button.visible = true
		aniplayer.play("button")

func _hovering(but: TextureButton):
	but.modulate = Color(0.6, 0.6, 0.6, 1.0)
	
func _nhovering(but: TextureButton):
	but.modulate = Color(1, 1, 1, 1)

func gonext():
	sfx.play()
	Gamestate.map_data = MapMaker.new().map_make()
	Gamestate.floors = 0
	Gamestate.create_play(chare)
	var nextt = get_tree().root
	nextt.get_node("Run").show_scene("map")
	
