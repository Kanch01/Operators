extends Control

var roots : Array = []

func _ready():
	print("print yourself")
	var root = MapNode.new().gen(10, 2)
	root.layout(root, 600, 0, 200, 100)
	roots = root.allnodes
	buildui(root)
	_draw()
	
func buildui(node):
	# Instead of preload, just make a Button on the fly:
	var btn = Button.new()
	btn.position = node.position
	# btn.text = node.instance.capitalize()
	btn.text = "lol"
	btn.disabled = true  # default to disabled if you only want children active
	add_child(btn)
	for child in node.children:
		buildui(child)

func _draw() -> void:
	for node in roots:
		for child in node.children:
			draw_line(node.position, child.position, Color(0, 0, 0), 2)
