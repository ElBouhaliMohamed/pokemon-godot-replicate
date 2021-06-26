extends Node

var confirmed_sound = load("res://Assets/Sounds/GUI sel decision.wav")

onready var _Body_AnimationPlayer = find_node("Body_AnimationPlayer")
onready var _Body_LBL = find_node("Body_Label")
onready var _Character_Texture = find_node("Character_Texture")
onready var _Dialog_Box = find_node("Dialog_Box")
onready var _Option_List = find_node("ChoiceBox")
onready var _Registry = find_node("Simulated_Registry")
onready var _Speaker_LBL = find_node("Speaker_Label")
onready var _SpaceBar_Icon = find_node("SpaceBar_NinePatchRect")
onready var ChoiceBox = find_node("ChoiceBox")
onready var Timer = find_node("Timer")

signal dialog_finished
signal next_node
signal populate_options(choices)
signal clear_options


var _did = 0
var _nid = 0
var _final_nid = 0
var _Story_Reader
var _texture_library : Dictionary = {}

export var LINE_LENGTH = 44
export var speedPerCharacter = 0.001
	
# Virtual Methods
func _ready():
	var Story_Reader_Class = load("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
	_Story_Reader = Story_Reader_Class.new()
	
	var story = load("res://Assets/Story/Example_Story_Baked.tres")
	_Story_Reader.read(story)
	
	#_load_textures()
	
	_Dialog_Box.visible = false
	_SpaceBar_Icon.visible = false
	_Option_List.visible = false
	
	Timer.wait_time = speedPerCharacter
	
	_clear_options()

func _input(event):
	if event.is_action_pressed("ui_accept") && !_is_waiting():
		Timer.wait_time = 0.0001
	elif event.is_action_released("ui_accept") && !_is_waiting():
		Timer.wait_time = speedPerCharacter

# Public Methods
func play_dialog(record_name : String):
	_did = _Story_Reader.get_did_via_record_name(record_name)
	_nid = _Story_Reader.get_nid_via_exact_text(_did, "<start>")
	_final_nid = _Story_Reader.get_nid_via_exact_text(_did, "<end>")
	_get_next_node()
	_play_node()
	_Dialog_Box.visible = true

# Private Methods
func _clear_options():
	emit_signal("clear_options")

func _display_image(key : String):
	_Character_Texture.texture = _texture_library[key]
	_Character_Texture.visible = true

func _get_next_node(slot : int = 0):
	_nid = _Story_Reader.get_nid_from_slot(_did, _nid, slot)
	
	if _nid == _final_nid:
		_Dialog_Box.visible = false
		emit_signal("dialog_finished")

func _get_tagged_text(tag : String, text : String) -> String:
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length()
	var end_index = text.find(end_tag)
	var substr_length = end_index - start_index
	return text.substr(start_index, substr_length)

func _inject_variables(text : String) -> String:
	var variable_count = text.count("<variable>")
	
	for i in range(variable_count):
		var variable_name = _get_tagged_text("variable", text)
		var variable_value = _Registry.lookup(variable_name)
		var start_index = text.find("<variable>")
		var end_index = text.find("</variable>") + "</variable>".length()
		var substr_length = end_index - start_index
		text.erase(start_index, substr_length)
		text = text.insert(start_index, str(variable_value))
	
	return text

func _is_waiting() -> bool:
	return _SpaceBar_Icon.visible

func _is_playing() -> bool:
	return _Dialog_Box.visible

func _load_textures():
	var did = _Story_Reader.get_did_via_record_name("DialogPlayer/TextureLibrary")
	var json_text = _Story_Reader.get_text(did, 1)
	var raw_texture_library : Dictionary = parse_json(json_text)
	
	for key in raw_texture_library:
		var texture_path = raw_texture_library[key]
		var loaded_texture = load(texture_path)
		_texture_library[key] = loaded_texture

func _play_node():
	var text = _Story_Reader.get_text(_did, _nid)
	text = _inject_variables(text)
	var speaker = _get_tagged_text("speaker", text)
	var dialog = _get_tagged_text("dialog", text)
	if "<choiceJSON>" in text:
		var options = _get_tagged_text("choiceJSON", text)
		_populate_choices(options)
	if "<image>" in text:
		var library_key = _get_tagged_text("image", text)
		_display_image(library_key)
	
	_set_speaker(speaker)

	_Body_LBL.set_lines_skipped(0)
	_Body_LBL.set_percent_visible(0)

	var processedText = _process_text(dialog)
	processedText = autoclip(processedText)
	_Body_LBL.text = processedText

	var percent_per_char = 1.0/float(processedText.length())
	var current = -1
	var eol1=-1
	var eol2=-1
	var skp=-1
	while (current < processedText.length()-1):
		current+=1
		_Body_LBL.set_percent_visible(percent_per_char*float(current-eol1))
		if (processedText[current]=='\n'):
			if (skp >= 0):
				_SpaceBar_Icon.show()
				while (!Input.is_action_just_pressed("ui_accept")):
					yield(get_tree(), "idle_frame")
				Timer.wait_time = speedPerCharacter
				SoundManager.play(0, self, confirmed_sound)
				_SpaceBar_Icon.hide()
			skp+=1
			eol1=eol2
			eol2=current-1
			_Body_LBL.set_lines_skipped(skp)
			_Body_LBL.set_percent_visible(percent_per_char*float(current-eol1))
		Timer.start()
		yield(Timer, "timeout")

	if _Option_List.find_node("OptionsContainer").get_child_count() != 0:
		_Option_List.show()
		var slot = yield(_Option_List, "option_selected")
		_Option_List.visible = false
		_Character_Texture.visible = false
		_get_next_node(slot)
		_clear_options()
		if _is_playing():
			_play_node()
	else:
		_SpaceBar_Icon.show()
		while (!Input.is_action_just_pressed("ui_accept")):
			yield(get_tree(), "idle_frame")
		SoundManager.play(0, self, confirmed_sound)
		_SpaceBar_Icon.hide()
		_get_next_node()
		if _is_playing():
			_play_node()

func _process_text(text):
	var delimiter = "\n"

	if(text.length() > LINE_LENGTH):
		var beforeDelimiter = text.substr(0, LINE_LENGTH)
		var afterDelimiter = text.substr(LINE_LENGTH)
		
		for index in range(beforeDelimiter.length()): # go through string
			var indexFromBack = (beforeDelimiter.length()-1) - index
			if beforeDelimiter[indexFromBack] == " ":
				afterDelimiter = beforeDelimiter.right(indexFromBack) + afterDelimiter
				beforeDelimiter = beforeDelimiter.left(indexFromBack)
				break
		
		var result = beforeDelimiter + delimiter + _process_text(afterDelimiter)
		return result
	else:
		return text
		
func autoclip(text=""):
	var lines = [""]
	for p in text.split("\n", false):
		for w in p.split(" ", false):
			if (lines[lines.size()-1].length()+w.length()+1 <= LINE_LENGTH):
				if lines[lines.size()-1] == "":
					lines[lines.size()-1] = w
				else:
					lines[lines.size()-1] += " "+w;
			else:
				lines.append(w)
	text = ""
	for l in range(lines.size()-1):
		text += lines[l] + "\n"
	text += lines[lines.size()-1]
	
	return text		

func _set_speaker(speaker):
	_Speaker_LBL.text = ""
	yield(get_tree(), "idle_frame")	
	emit_signal("next_node")
	yield(get_tree(), "idle_frame")	
	_Speaker_LBL.text = speaker

func _populate_choices(JSONtext : String):
	var choices : Dictionary = parse_json(JSONtext)
	emit_signal("populate_options", choices)



