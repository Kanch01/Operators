extends Control
class_name Shop

# still need to add the selling of passive items
# the adding of bought items to the inventory panel
# the populating of passive items
# adding items for display in battle
# making consumables usable in battle
# making itmes visible in map

@onready var path1: TextureButton = $ShopRect/ItemOne
@onready var path2: TextureButton = $ShopRect/ItemTwo
@onready var path3: TextureButton = $ShopRect/ItemThree
@onready var path4: TextureButton = $ShopRect/ItemFour

@onready var text_display: Label = $ShopRect/Info
@onready var buy: Button = $ShopRect/Buy
@onready var leave: Button = $ShopRect/Leave

@onready var muns = $ShopRect/Money
@onready var sell: Button = $ShopRect/Sell

@onready var fslot: TextureButton = $InvenPOne
@onready var sslot: TextureButton = $InvenPTwo
@onready var cslot: TextureButton = $InvenConsume

@onready var reroll: Button = $Reroll

var items = []
var selected_item
var selected_inven
var selected_path: TextureButton
var to_remove: String
var tw: Tween

func _ready():
	if Gamestate.reroll == true:
		reroll.visible = true
		reroll.pressed.connect(roll_again)
		
	_populate_inven()
	_populate_shop()
	
	path1.pressed.connect(_displays.bind(0, path1))
	path2.pressed.connect(_displays.bind(1, path2))
	path3.pressed.connect(_displays.bind(2, path3))
	path4.pressed.connect(_displays.bind(3, path4))
	
	cslot.pressed.connect(_enable_sell.bind("cons"))
	fslot.pressed.connect(_enable_sell.bind("pass1"))
	sslot.pressed.connect(_enable_sell.bind("pass2"))
	
	buy.pressed.connect(_add_item)
	leave.pressed.connect(_leave_shop)
	sell.pressed.connect(_sell)
	
	await get_tree().create_timer(0.4).timeout 
	var ftext = "Welcome to the Shop\n Select an item to see its cost and effect\n If you wish to buy nothing, simply click 'LEAVE'"
	_display_text(ftext)
	
func roll_again():
	if Gamestate.muns <= Gamestate.rerollamt:
		_display_text("Not enough coins to reroll items")
	else:
		muns.add_money(0 - Gamestate.rerollamt)
		Gamestate.rerollamt += 100
		reroll.text = "Reroll\n" + str(Gamestate.rerollamt)
		_populate_shop()
	
func _populate_inven():
	if Gamestate.consumable:
		cslot.texture_normal = load(Gamestate.consumable.get("path"))
		cslot.disabled = false
	
	if Gamestate.passive_item_inventory[0] != {}:
		fslot.texture_normal = load(Gamestate.passive_item_inventory[0].get("path"))
		fslot.disabled = false
	if Gamestate.passive_item_inventory[1] != {}:
		sslot.texture_normal = load(Gamestate.passive_item_inventory[1].get("path"))
		sslot.disabled = false
			
func _enable_sell(item_type):
	if Gamestate.consumable and item_type == "cons":
		selected_inven = Gamestate.consumable
		_display_text(Gamestate.consumable.get("name") + " selected, sells for " + str((selected_inven.get("cost") / 2)))
	
	if item_type == "pass1" and Gamestate.passive_item_inventory[0]:
		selected_inven = Gamestate.passive_item_inventory[0]
		_display_text(Gamestate.passive_item_inventory[0].get("name") + " selected, sells for " + str((selected_inven.get("cost") / 2)))
		
	if item_type == "pass2" and Gamestate.passive_item_inventory[1]:
		selected_inven = Gamestate.passive_item_inventory[1]
		_display_text(Gamestate.passive_item_inventory[1].get("name") + " selected, sells for " + str((selected_inven.get("cost") / 2)))
	
	to_remove = item_type
	sell.disabled = false
	
func _sell():
	muns.add_money(selected_inven.get("cost") / 2)
	if selected_inven.get("passive") == true:
		selected_inven.get("sell_function").call()
	if to_remove == "cons":
		Gamestate.consumable = null
		cslot.texture_normal = null
		cslot.disabled = true
	elif to_remove == "pass1":
		Gamestate.passive_item_inventory[0] = {}
		fslot.texture_normal = null
		fslot.disabled = true
	else:
		Gamestate.passive_item_inventory[1] = {}
		sslot.texture_normal = null
		sslot.disabled = true
	
	Gamestate.ITEMS.get(selected_inven.get("key")).set("owned", false)
	sell.disabled = true
	_display_text("Item sold")
	

func _displays(indx: int, button_s):
	selected_path = button_s
	sell.disabled = true
	selected_item = items[indx]
	var itext = items[indx].get("name") + ": " + str(items[indx].get("cost")) + " Coins\n" + items[indx].get("effect")
	_display_text(itext)

func _populate_shop():
	var nums = []
	items = []
	while nums.size() < 4:
		var rnum = randi_range(0, 14)
		if rnum not in nums:
			if Gamestate.ITEMS.get(rnum).get("owned") == false:
				nums.append(rnum)
				items.append(Gamestate.ITEMS.get(rnum))
	
	items[0] = Gamestate.ITEMS.get(4)
	
	path1.texture_normal = load(items[0].get("path"))
	path2.texture_normal = load(items[1].get("path"))
	path3.texture_normal = load(items[2].get("path"))
	path4.texture_normal = load(items[3].get("path"))
	
func _display_text(texts: String):
	if tw and tw.is_running():
		tw.kill()
	text_display.text = texts
	text_display.visible_characters = 0
	var dur = texts.length() / max(1.0, 25.0)
	tw = create_tween()
	tw.tween_property(text_display, "visible_characters", texts.length(), dur)
		
func _leave_shop():
	Gamestate.rerollamt = 250
	move_on()
	
func _add_item():
	if selected_item.get("passive") == true and Gamestate.passive_item_inventory.has({}) == false:
		_display_text("Must sell a non-single use item before buying")
	elif selected_item.get("passive") == false and Gamestate.consumable:
		_display_text("Must sell a single use item before buying")
	elif selected_item.get("cost") > Gamestate.muns:
		_display_text("Not enough coins")
	else:
		Gamestate.ITEMS.get(selected_item.get("key")).set("owned", true)
		muns.add_money(0 - selected_item.get("cost"))
		selected_path.texture_normal = null
		selected_path.disabled = true
		if selected_item.get("passive") == false:
			Gamestate.consumable = selected_item
		else:
			selected_item.get("function").call()
			if Gamestate.passive_item_inventory[0] == {}:
				Gamestate.passive_item_inventory[0] = selected_item
			else:
				Gamestate.passive_item_inventory[1] = selected_item
		
		_populate_inven()
		_display_text("Once you are done shopping please click 'LEAVE'")

func move_on():
	var par = get_tree().root
	par.get_node("Run").show_scene("map")
