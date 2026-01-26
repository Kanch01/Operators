extends Area2D
class_name MapRoom

signal selected(room: Room)

const ICONS := {
	Room.Type.NA: [null, Vector2.ONE],
	Room.Type.BATTLE: [preload("res://assets/UI/BIcon.png"), Vector2(0.09, 0.09)],
	Room.Type.BOSS: [preload("res://assets/UI/KIcon.png"), Vector2(0.09, 0.09)],
	Room.Type.SHOP: [preload("res://assets/UI/SIcon.png"), Vector2(0.09, 0.09)],
	Room.Type.HEAL: [preload("res://assets/UI/HIcon.png"), Vector2(0.09, 0.09)],
	Room.Type.TREASURE: [preload("res://assets/UI/TIcon.png"), Vector2(0.09, 0.09)]
}

@onready var sprite2d: Sprite2D = $Visuals/Sprite2D
@onready var line2d: Line2D = $Visuals/Line2D
@onready var aniplayer: AnimationPlayer = $AnimationPlayer
@onready var sfx = $".".get_node("/root/Run/SFX")

var available := false : set = set_available
var room: Room : set = set_room

func set_available(val: bool):
	available = val
	
	if available:
		aniplayer.play("highlight")
	elif not room.selected:
		aniplayer.play("RESET")
		
func set_room(data: Room):
	room = data
	position = room.position
	line2d.rotation_degrees = 90 # can disable so all are set the same
	sprite2d.texture = ICONS[room.type][0]
	sprite2d.scale = ICONS[room.type][1]
	
func show_selected():
	line2d.modulate = Color.WHITE
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return
	sfx.play()
	room.selected = true
	aniplayer.play("select")
	
func _on_map_room_selected():
	selected.emit(room)
