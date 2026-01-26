extends Node
class_name MapMaker

const X_DIST := 100
const Y_DIST := 100
const RANDOMNESS := 50 # can change for more org
const FLOORS := 15 # change for depth
const MAP_WIDTH := 7 # change for possible branches
const PATHS := 6 # change for branches
const BATTLE_PROB := 5.0
const SHOP_PROB := 3.5
const HEAL_PROB := 3.5
const TREASURE_PROB := 3.5
# can change code so that treasure is also a possible room

var random_room_probs = {
	Room.Type.BATTLE: 0.0,
	Room.Type.HEAL: 0.0,
	Room.Type.SHOP: 0.0,
	Room.Type.TREASURE: 0.0
}

var rand_room_total := 0
var map_data: Array[Array]

# func _ready():
	# map_make()

func map_make() -> Array[Array]:
	map_data = _make_grid()
	var start_points := _get_rand_start_points()
	
	for j in start_points:
		var curr_j := j
		for i in FLOORS - 1: 
			curr_j = _setup_conn(i, curr_j)
			
	_set_boss()
	_set_rand_room_wt()
	_set_room_type()
	
	#var i := 0
	#for floor in map_data:
		#print("floor %s" % i)
		#var used = floor.filter(
		#	func(room: Room): return room.next_rooms.size() > 0
		#)
		#print(used)
		#i += 1
	
	return map_data
	
func _make_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adj_rooms : Array[Room] = []
		for j in MAP_WIDTH:
			var curr_room := Room.new()
			var offset := Vector2(randf(), randf()) * RANDOMNESS
			curr_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			curr_room.row = i
			curr_room.column = j
			curr_room.next_rooms = []
			
			if i == FLOORS - 1:
				curr_room.position.y = (i + 1) * -Y_DIST
				
			adj_rooms.append(curr_room)		
		result.append(adj_rooms)
	return result
	
func _get_rand_start_points() -> Array[int]:
	var y_cords: Array[int]
	var unique_pts: int = 0
	
	# can change func if only want two points
	while unique_pts < 2: # can change depending on how many pts wanted
		unique_pts = 0
		y_cords = []
		
		for i in PATHS:
			var start_pt := randi_range(0, MAP_WIDTH - 1)
			if not y_cords.has(start_pt):
				unique_pts += 1
				
			y_cords.append(start_pt)
	return y_cords
		
func _setup_conn(i: int, j: int):
	var next_room: Room
	var curr_room := map_data[i][j] as Room
	
	while not next_room or _crosses_path(i, j, next_room):
		var rand_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][rand_j]
	curr_room.next_rooms.append(next_room)
	
	return next_room.column
	
func _crosses_path(i: int, j: int, room: Room):
	var left: Room
	var right: Room
	
	if j > 0:
		left = map_data[i][j - 1]		
	if j < MAP_WIDTH - 1:
		right = map_data[i][j + 1]
	
	if right and room.column > j:
		for next_room: Room in right.next_rooms:
			if next_room.column < room.column:
				return true
	if left and room.column < j:
		for next_room: Room in left.next_rooms:
			if next_room.column > room.column:
				return true
				
	return false

func _set_boss():
	var middle := floori(MAP_WIDTH * 0.5)
	var boss := map_data[FLOORS - 1][middle] as Room
	
	for j in MAP_WIDTH:
		var curr_room = map_data[FLOORS - 2][j] as Room
		if curr_room.next_rooms:
			curr_room.next_rooms = [] as Array[Room]
			curr_room.next_rooms.append(boss)
			
	boss.type = Room.Type.BOSS
	
func _set_rand_room_wt():
	random_room_probs[Room.Type.BATTLE] = BATTLE_PROB
	random_room_probs[Room.Type.HEAL] = BATTLE_PROB + HEAL_PROB
	random_room_probs[Room.Type.SHOP] = BATTLE_PROB + HEAL_PROB + SHOP_PROB
	random_room_probs[Room.Type.TREASURE] = BATTLE_PROB + HEAL_PROB + SHOP_PROB + TREASURE_PROB
	
	rand_room_total = random_room_probs[Room.Type.TREASURE]

func _set_room_type():
	# will change later to not make everything a battle automatically
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.BATTLE
	
	'''
	for room: Room in map_data[8]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE
	for room: Room in map_data[13]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.HEAL
	'''
			
	for curr_floor in map_data:
		for room: Room in curr_floor:
			for next: Room in room.next_rooms:
				if next.type == Room.Type.NA:
					_set_room_rand(next)
					
func _set_room_rand(room):
	var heal_below_four := true
	var consec_heal := true
	var consec_shop := true
	var heal_on_boss := true
	
	var candidate: Room.Type
	
	while heal_below_four or consec_heal or consec_shop or heal_on_boss:
		candidate = _get_rand_room_by_wt()
		
		var is_heal := candidate == Room.Type.HEAL
		var heal_parent := _room_has_parent(room, Room.Type.HEAL)
		var is_shop := candidate == Room.Type.SHOP
		var shop_parent := _room_has_parent(room, Room.Type.SHOP)
		
		heal_below_four = is_heal and room.row < 3
		consec_heal = is_heal and heal_parent
		consec_shop = is_shop and shop_parent
		heal_on_boss = is_heal and room.row == 12
	room.type = candidate
	
func _get_rand_room_by_wt():
	var roll := randf_range(0.0, rand_room_total)
	for type: Room.Type in random_room_probs:
		if random_room_probs[type] > roll:
			return type
	return Room.Type.BATTLE
	
func _room_has_parent(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	
	if room.column > 0 and room.row > 0:
		var candidate := map_data[room.row - 1][room.column - 1] as Room
		if candidate.next_rooms.has(room):
			parents.append(candidate)
	if room.row > 0:
		var candidate := map_data[room.row - 1][room.column] as Room
		if candidate.next_rooms.has(room):
			parents.append(candidate)
	if room.column < MAP_WIDTH - 1 and room.row > 0:
		var candidate := map_data[room.row - 1][room.column + 1] as Room
		if candidate.next_rooms.has(room):
			parents.append(candidate)
			
	for parent: Room in parents:
		if parent.type == type:
			return true
			
	return false
