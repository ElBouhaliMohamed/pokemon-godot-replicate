extends Control

onready var _Option_Button_Scene = load("res://GUI/Option.tscn")
var cursor_sound = load("res://Assets/Sounds/GUI sel cursor.wav")
var confirmed_sound = load("res://Assets/Sounds/GUI sel cursor.wav")

signal option_selected(slot)

var options = []
var selected_option = 0
var enabled = false

onready var optionsContainer = find_node("OptionsContainer")
onready var cursor = $Cursor
#onready var DialogPlayer = get_node(NodePath("/root/Game/Dialog_Player"))

func _process(delta):
	if enabled:
		if Input.is_action_just_pressed("ui_up"):
			options[selected_option].active = false

			if selected_option < options.size()-1:
				selected_option += 1
			else:
				selected_option = 0

			options[selected_option].active = true
			position_cursor(options[selected_option])
		elif Input.is_action_just_pressed("ui_down"):
			if selected_option <= options.size()-1 && selected_option >= 0:
				options[selected_option].active = false
				selected_option -= 1
				if selected_option < 0:
					selected_option = options.size() - 1

				options[selected_option].active = true
				position_cursor(options[selected_option])

func position_cursor(option: Label):
	SoundManager.play(0,self,cursor_sound)
	cursor.position.y = option.rect_position.y + (cursor.texture.get_height()*cursor.get_scale().y)
	Log.trace(self, "position_cursor", "Selected option %d" %selected_option)
	

func populate_options(choices):
	var index = 0
	for text in choices:
		var slot = choices[text]
		var new_option_button = _Option_Button_Scene.instance()
		new_option_button.slot = slot
		new_option_button.set_text(text)
		new_option_button.connect("clicked", self, "_on_Option_clicked")
		options.push_front(new_option_button)
		
		if(index == choices.size()-1):
			selected_option = index
			new_option_button.active = true
		
		optionsContainer.add_child(new_option_button)
		index += 1
	position_cursor(options[selected_option])
	enabled = true

func clear_options():
	selected_option = 0
	options = []
	var children = optionsContainer.get_children()
	for child in children:
		optionsContainer.remove_child(child)
		child.queue_free()

func _on_Option_clicked(slot):
	SoundManager.play(0,self,confirmed_sound)
	emit_signal("option_selected", slot)
	enabled = false
