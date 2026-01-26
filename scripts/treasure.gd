extends Control
class_name Treasure

@onready var num_one: Button = $Book1/Num1
@onready var num_two: Button = $Book2/Num2
@onready var label: Label = $Label

@onready var bag: Control = $Bag

@onready var add: Button = $Add
@onready var delete: Button = $Delete
@onready var timer: Timer = $Timer

var to_remove: String
var tw: Tween
var sel_num: String
var pos_nums: Array = [1, 2, 6, 7, 9, 11, 8, 10, 3]
var to_get_rid

func _ready():
	var disp = "These are Permas, they are numbers that are always available for use. Pick one and it will sit next to your other numbers forever"
	_display_text(disp)
	_populate_nums()
	
	num_one.pressed.connect(show_add.bind(num_one.text))
	num_two.pressed.connect(show_add.bind(num_two.text))
	
	add.pressed.connect(give_num)
	delete.pressed.connect(remove_num)
	
	_populate_bag()
	
	for child: Button in bag.get_children():
		child.pressed.connect(show_delete.bind(child))
	
func show_delete(child):
	delete.disabled = false
	add.disabled = true
	to_get_rid = child
	
func remove_num():
	Gamestate.perma_numbers.erase(int(to_get_rid.text))
	to_get_rid.text = ""
	to_get_rid.disabled = true
	_display_text("Successfully deleted number")

func _populate_nums():
	var to_add = []
	
	while to_add.size() != 2:
		var random = randi() % 9
		if pos_nums[random] not in Gamestate.perma_numbers:
			to_add.append(pos_nums[random])
			
	num_one.text = str(to_add[0])
	num_two.text = str(to_add[1])

func show_add(num: String):
	sel_num = num
	delete.disabled = true
	add.disabled = false
	
func _populate_bag():
	for i in range(Gamestate.perma_numbers.size()):
		bag.get_child(i).text = str(Gamestate.perma_numbers[i])
		bag.get_child(i).disabled = false

func give_num():
	if Gamestate.perma_numbers.size() == 3:
		_display_text("Must remove a Perma before adding a new one")
	else:
		_display_text("Added new number")
		Gamestate.perma_numbers.append(int(sel_num))
		add.disabled = true
		_populate_bag()
		num_one.text = ""
		num_two.text = ""
		timer.start()
		
		await timer.timeout
		move_on()
		
func _display_text(texts: String):
	if tw and tw.is_running():
		tw.kill()
	label.text = texts
	label.visible_characters = 0
	var dur = texts.length() / max(1.0, 25.0)
	tw = create_tween()
	tw.tween_property(label, "visible_characters", texts.length(), dur)

func move_on():
	var par = get_tree().root
	par.get_node("Run").show_scene("map")
