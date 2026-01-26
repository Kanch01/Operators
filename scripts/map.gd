extends Node2D
class_name Map

const SCROLL_SPEED := 30
const MAP_ROOM = preload("res://scenes/map_room.tscn")
const MAP_LINE = preload("res://scenes/map_line.tscn")

@onready var map_generator: MapMaker = $MapMaker
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera2d: Camera2D = $Camera2D
@onready var sfx = $".".get_node("/root/Run/SFX")

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room
var camera_edge_y: float


func _ready():
	print("map is actually called")
	camera2d.enabled = true
	camera2d.make_current()
	camera_edge_y = MapMaker.Y_DIST * (MapMaker.FLOORS - 1)
	map_data = Gamestate.map_data
	floors_climbed = Gamestate.floors
	last_room = Gamestate.curr_room
	create_map()
	if Gamestate.floors == 0:
		unlock_floor(0)
	else:
		unlock_next_room()
	
	
#	gen_new_map()
#	unlock_floor(0)
	
func _input(event: InputEvent):
	if event is InputEventPanGesture:
		camera2d.position.y += event.delta[1] * SCROLL_SPEED
	
	camera2d.position.y = clamp(camera2d.position.y, -camera_edge_y, 150)
	
func gen_new_map():
	floors_climbed = 0
	map_data = map_generator.map_make()
	create_map()
	
func create_map():
	for curr_floor: Array in map_data:
		for room: Room in curr_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
				
	var middle := floori(MapMaker.MAP_WIDTH * 0.5)
	_spawn_room(map_data[MapMaker.FLOORS - 1][middle])
	var map_width := MapMaker.X_DIST * (MapMaker.MAP_WIDTH- 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width) / 2
	visuals.position.y = get_viewport_rect().size.y / 2
	
func unlock_floor(which: int = floors_climbed):
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which:
			map_room.available = true
			
func unlock_next_room():
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true
			
func show_map():
	show()
	camera2d.enabled = true
	
func hide_map():
	hide()
	camera2d.enabled = false
	
func _spawn_room(room: Room):
	var new_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_room)
	new_room.room = room
	new_room.selected.connect(on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_room.show_selected()
		
func _connect_lines(room: Room):
	if room.next_rooms.is_empty():
		return
		
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)
		
func on_map_room_selected(room: Room):
	hide_map()
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
			
	last_room = room
	Gamestate.curr_room = room
	floors_climbed += 1
	Gamestate.floors += 1
	Gamestate.map_data = map_data
	var par = get_tree().root
	par.get_node("Run").show_scene(room._to_string())
	
