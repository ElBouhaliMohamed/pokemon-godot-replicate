extends Component

export (Array, Dictionary) var paths

var labels = []

func _init().("Debug"):
	pass

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_debug"):
			enabled = !enabled
			if enabled:
				$PopupPanel.call_deferred("popup")
			else:
				$PopupPanel.hide()

func _ready():
	_create_labels()

	# Show the debug overlay.
	if enabled:
		$PopupPanel.call_deferred("popup")

func _process(_delta):
	_update_position()
	_update_labels()


# PRIVATE FUNCTIONS
# -----------------
func _create_labels():
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Assets/Fonts/Pokemon_GB.ttf")
	dynamic_font.size = 10
	dynamic_font.outline_size = 1
	dynamic_font.outline_color = Color(0,0,0)
	
	for entry in paths:
		var property_path = entry.property
		var node_path = entry.path
		property_path = (String(node_path) + property_path) as NodePath
		var property = _get_node_property(get_parent(), property_path)
		if debug:
			Log.trace(self, "_create_labels", String(property))
		
		var label = Label.new()
		if property.value == null:
			property.value = "null"
		
		label.name = String(property.name)
		label.text = String(property.name) + ": " + String(property.value)
		label.add_font_override("font", dynamic_font)
		labels.push_front(label)
		$PopupPanel/VBoxContainer.add_child(label)

func _update_position():
	$PopupPanel.rect_position = entity.position - ($PopupPanel.rect_size/2)

func _update_labels():
	for entry in paths:
		var property_path = entry.property
		var node_path = entry.path
		property_path = (String(node_path) + property_path) as NodePath
		var property = _get_node_property(get_parent(), property_path)
		var property_name = String(property.name)
		
		if debug:
			Log.trace(self, "_update_labels", String(property))
		
		var label_name = property_name.replace(":", "")
		for label in labels:
			if label.name == label_name:
				label.name = property_name
				label.text = property_name + ":" + String(property.value)
		
func _get_node_property(from: Node, path: NodePath):
	assert(":" in path as String)  # Causes a hard crash
	path = path as NodePath
	var node_path = _get_as_node_path(path)
	var property_path = (path.get_concatenated_subnames() as NodePath).get_as_property_path()
	if debug:
		Log.trace(self, "_get_node_property", String(path))
		Log.trace(self, "_get_node_property", String(node_path))
		Log.trace(self, "_get_node_property", String(property_path))
	var node = from.get_node(node_path)
	var value = node.get_indexed(property_path)
	return {"name": property_path, "value": value} 

func _get_as_node_path(path: NodePath) -> NodePath:
	assert(":" in path as String)
	path = path as NodePath
	var node_path = path as String
	var property_path = path.get_concatenated_subnames() as String
	node_path.erase((path as String).length() - property_path.length() - 1, property_path.length() + 1)
	return node_path as NodePath
