extends Node
@onready var container: Node = $SceneContainer
@onready var transitions: Transition = $Intermittent

const SCENES = {
	"main_menu": preload("res://scenes/MainMenu.tscn"),
	"character_select": preload("res://scenes/char_select.tscn"),
	"map": preload("res://scenes/map.tscn"),
	"BATTLE": preload("res://scenes/bb.tscn"),
	"SHOP": preload("res://scenes/Shop.tscn"),
	"TREASURE": preload("res://scenes/Treasure.tscn"),
	"HEAL": preload("res://scenes/heal.tscn"),
	"BOSS": preload("res://scenes/bb.tscn"),
	"difficulty": preload("res://scenes/difficulty.tscn")
}
var key2
	
func _ready():
	transitions.next_one.connect(_next_scene)
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		#child.call_deferred("free")
		
	var path = SCENES.get("main_menu")
	var sc = path.instantiate()
	container.add_child(sc)
	
func show_scene(key: String):
	key2 = key
	transitions.visible = true
	transitions.expand_blackout(0.9)
		#child.call_deferred("free")
	
	# transitions.visible = true
	
func _next_scene():
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		
	var path = SCENES.get(key2)
	var sc = path.instantiate()
	container.add_child(sc)
	
	transitions.contract_blackout(0.9)
	
	#call_deferred("_do_scene", path)

#func _do_scene(path):
	#var sc = path.instantiate()
	#container.add_child(sc)
	
	
	
