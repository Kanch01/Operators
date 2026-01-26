extends Resource
class_name Room

enum Type {NA, BATTLE, TREASURE, SHOP, HEAL, BOSS}

@export var type : Type
@export var row : int
@export var column : int
@export var position : Vector2
@export var next_rooms : Array[Room]
@export var selected := false

func _to_string() -> String:
	return "%s" % Type.keys()[type]
