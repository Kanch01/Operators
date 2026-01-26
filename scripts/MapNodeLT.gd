extends Node

class_name MapNode

var id : int
var instance : String
var children : Array = []
var position : Vector2
var depth_level : int # diff
var enemies : Array =[]
var rewards : Array = []
var allnodes : Array = []

# builds tree
func _build(maxd, maxb, cnt, d):
	var node = MapNode.new()
	node.id = cnt
	cnt += 1
	node.instance = "Battle" # rep with func
	node.depth_level = d
	if d < maxd:
		var branches = randi_range(1, maxb)
		for i in branches:
			node.children.append(_build(maxd, maxb, cnt, d + 1))
	return node

# generates tree
func gen(maxd, maxb):
	var root = _build(maxd, maxb, 0, 0)
	return root

# determines display spacing, hor and ver
func layout(node, x, y, xspace, yspace):
	node.position = Vector2(x, y)
	allnodes.append(node)
	var child_x = x - (node.children.size()-1) * xspace * 0.5
	for child in node.children:
		layout(child, child_x, y + yspace, xspace, yspace)
		child_x += xspace
		
func debug_print_tree(node: MapNode, depth) -> void:
	# build an indent string ("  " per depth level)
	var indent := ""
	for i in range(depth):
		indent += "  "
	# print this node’s key info
	print(indent, node.id, node.instance, node.position)
	# recurse into children
	for child in node.children:
		debug_print_tree(child, depth + 1)
