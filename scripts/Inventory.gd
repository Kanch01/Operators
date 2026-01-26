extends Node
class_name Inventory

# all characters have the same hand
# numberset is the set of all numbers available
# hand is the numbers that are to be displayed

var numberset: Array[int] = [2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 8, 8, 10]
var hand: Array[int] = []
var discard_pile: Array[int] = []

# initial hand draw
func draw_hand():
	for i in range(9):
		var rnum = randi() % numberset.size()
		hand.append(numberset[rnum])
		numberset.remove_at(rnum)
	
# function used for Helping Hand ability	
func redraw():
	for num in hand:
		numberset.append(num)
		
	hand = []
	draw_hand()
		
func new_number(num):
	numberset.append(num)
	
func use_number(num):
	if hand.has(num):
		hand.erase(num)
		discard_pile.append(num)
		
func return_number(num):
	if num in discard_pile:
		discard_pile.erase(num)
		hand.append(num)
		
# consecutive draws, after initial
func after_draws():
	var draws: int = 0
	if numberset.size() == 0:
		numberset += discard_pile
		discard_pile.clear()
		
	while hand.size() <= 9 and numberset.size() > 0 and draws < 3:
		var rnum = randi() % numberset.size()
		hand.append(numberset[rnum])
		numberset.remove_at(rnum)
		draws += 1
		
func reset_full_hand():
	if hand.size() > 0:
		numberset += hand
		hand.clear()
	if discard_pile.size() > 0:
		numberset += discard_pile
		discard_pile.clear()

	for i in range(9):
		if numberset.is_empty():
			break
		var rnum = randi() % numberset.size()
		hand.append(numberset[rnum])
		numberset.remove_at(rnum)
