extends Panel

var text = []
var box_is_finished = false
var can_skip = true
var current_page = 0
var pages = 0
onready var animationPlayer = get_node(NodePath("/root/Game/Gui/AnimationPlayer"))
onready var font = load("res://Assets/Fonts/pokemon_gb.tres")

const chars_per_line = 40
const lines_per_box = 3

signal dialog_started
signal dialog_finished

var textBox : Label

	
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		if can_skip || box_is_finished:
			next_dialog()
	
func show_message(message: String, can_skip: bool = true):
	emit_signal("dialog_started")
	current_page = 0
	text = parse_string(message)
	pages = text.size()
	#start_dialog()
	create_label()
	
func create_label():
	textBox = Label.new()
	textBox.set_size(Vector2(200,200))
	textBox.add_font_override("normal_font", font)
	textBox.text = "Dies ist ein Test"
	textBox.add_color_override("font_color", Color(1,0,0))
	textBox.percent_visible = 1
	textBox.show_on_top = true
	add_child(textBox)
	
	
func start_dialog():
	create_label()
	textBox.text = text[current_page]
	animationPlayer.play("TypeWriter")
	yield(animationPlayer, "animation_finished")
	
func next_dialog():
	if current_page < pages:
		# still dialog to go
		textBox.percent_visible = 0
		current_page += 1
	else:
		# finished dialog
		emit_signal("dialog_finished")
		
	
func parse_string(text: String):
	var parsed_string = []
	
	var current_text = ""
	var previous_line = 0
	var next_line = 0
	var current_line_count = 0
	
	for index in text.length():
		current_line_count += 1
		previous_line = next_line
		next_line = text.find('\n', 0)
		if next_line == -1:
			current_text += text.substr(previous_line, text.length())
		else:
			current_text += text.substr(previous_line, next_line)
			
		if current_line_count == lines_per_box:
			parsed_string.push_front(current_text)
			current_text = ""
			previous_line = 0
			next_line = -1
			current_line_count = 0 
			
	return parsed_string
