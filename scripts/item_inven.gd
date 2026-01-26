extends Control

@onready var item_one: TextureButton = $PassOne
@onready var item_two: TextureButton = $PassTwo
@onready var consumable: TextureButton = $Consume
@onready var infobox: TextureRect = $TextureRect
@onready var infoinfo: Label = $TextureRect/Label
@onready var use_button: Button = $TextureRect/Button

@onready var p_health: TextureProgressBar = $".".get_node("/root/Run/SceneContainer/BB/Health")
@onready var p_label: Label = $".".get_node("/root/Run/SceneContainer/BB/Health/Label")
@onready var battle = $".".get_node("/root/Run/SceneContainer/BB")


func _ready():
	item_one.mouse_entered.connect(show_rect.bind(true, Gamestate.passive_item_inventory[0]))
	item_two.mouse_entered.connect(show_rect.bind(true, Gamestate.passive_item_inventory[1]))
	consumable.mouse_entered.connect(show_rect.bind(false, Gamestate.consumable))
	use_button.pressed.connect(use_consumable)
	
	# infobox.mouse_exited.connect(hide_rect)
	
	populate_inven()

func show_rect(passive: bool, item):
	if passive == false and not Gamestate.consumable:
		return
	elif item == {}:
		return
	elif passive == false:
		use_button.visible = true
		if use_button.is_connected("pressed", use_draining):
			use_button.disconnect("pressed", use_draining)
			use_button.pressed.connect(use_consumable)
	elif item.get("name") == "Draining Hit":
		use_button.visible = true
		if use_button.is_connected("pressed", use_consumable):
			use_button.disconnect("pressed", use_consumable)
		else:
			use_button.disconnect("pressed", use_draining)
		
		use_button.pressed.connect(use_draining)
	else:
		use_button.visible = false
		
	infobox.visible = true
	infoinfo.text = item.get("name") + "\n" + item.get("effect")
	
func hide_rect():
	infobox.visible = false
	use_button.visible = false

func use_draining():
	Gamestate.sacrifice = true

func use_consumable():
	hide_rect()
	
	Gamestate.consumable.get("function").call()
	Gamestate.ITEMS.get(Gamestate.consumable.get("key")).set("owned", false)
	if Gamestate.consumable.get("name") == "Porta Heal":
		battle.bleeding()
		p_health.value = Gamestate.pstats.health
		p_label.text = str(Gamestate.pstats.health) + "/" + str(Gamestate.pstats.max_health)
	if Gamestate.consumable.get("name") == "Perfect Split":
		battle.enemy.stats.health = battle.enemy.stats.health / 2
		battle.enemy.update_stats()
	if Gamestate.consumable.get("name") == "Stevens":
		if battle.enemy.stats.health % 2 != 0:
			battle.enemy.stats.health -= 1
	if Gamestate.consumable.get("name") == "Subs":
		Gamestate.sub_based = true
	
	consumable.disabled = true
	consumable.texture_normal = null
	Gamestate.consumable = null


func populate_inven():
	if Gamestate.consumable:
		consumable.disabled = false
		consumable.texture_normal = load(Gamestate.consumable.get("path"))
	if Gamestate.passive_item_inventory[0] != {}:
		item_one.disabled = false
		item_one.texture_normal = load(Gamestate.passive_item_inventory[0].get("path"))
	if Gamestate.passive_item_inventory[1] != {}:
		item_two.disabled = false
		item_two.texture_normal = load(Gamestate.passive_item_inventory[1].get("path"))
