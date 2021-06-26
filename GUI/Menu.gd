extends CanvasLayer

var menu = [
	{
		"name": "POKEMON",
		"icon": "res://Assets/Menu/itemRM1.png"
	},
	{
		"name": "POKEDEX",
		"icon": "res://Assets/Menu/itemRM3.png"
	},
	{
		"name": "BAG",
		"icon": "res://Assets/Menu/itemRM4.png"
	},
	{
		"name": "TRAINER",
		"icon": "res://Assets/Menu/itemRMT.png"
	},
	{
		"name": "MAP",
		"icon": "res://Assets/Menu/itemRM2.png"
	},
	{
		"name": "SAVE",
		"icon": "res://Assets/Menu/itemRMS.png"
	},
	{
		"name": "POKEGEAR",
		"icon": "res://Assets/Menu/itemRM5.png"
	},
	{
		"name": "OPTIONS",
		"icon": "res://Assets/Menu/itemRMO.png"
	}
]

export var MENU_DISTANCE = 38
export var SCALE = 0.7
export var ACTIVE_SCALE = 0.9
export var BASE_ANGLE = -(PI/2)
export var ENABLE_CLOCK = true
export var ANIMATION_SPEED = 0.15
export var MENU_FONT_SIZE = 50
export var MENU_FONT_OUTLINE_SIZE = 1


export(Color) var ACTIVE_TONE = Color(1,1,1,1) # Tone (Red, Green, Blue, Grey) shift applied to active icon.
export(Color) var INACTIVE_TONE = Color(1,1,1,0.4) # Tone (Red, Green, Blue, Grey) shift applied to inactive icon. 
export(Color) var MENU_TEXTCOLOR = Color(0,0,0) 
export(Color) var MENU_TEXTOUTLINE = Color(1,1,1) 
#export(float) var BACKGROUND_OPACITY = 0.5 

var radius = BASE_ANGLE * MENU_DISTANCE
var entrys = []
var selected_entry = 0
var enabled = false

var player = null
var color_before_tint : Color
var canvasModulate : CanvasModulate
var entryName : Label
var clock : Label
var dynamic_font : DynamicFont

var open_sound = load("res://Assets/Sounds/GUI menu open.wav")
var quit_sound = load("res://Assets/Sounds/se_gui_close.wav")
var cursor_sound = load("res://Assets/Sounds/GUI sel cursor.wav")

func _ready():
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Assets/Fonts/Pokemon_GB.ttf")
	dynamic_font.size = MENU_FONT_SIZE
	dynamic_font.outline_size = MENU_FONT_OUTLINE_SIZE
	dynamic_font.outline_color = MENU_TEXTOUTLINE

	canvasModulate = find_parent("Game").get_node("DayNightCycle")
	create_menu()
	
	
func _process(delta):
	if Input.is_action_just_pressed("menu"):
		enabled = !enabled
		if enabled:
			show_menu()
		else:
			hide_menu()
			
	if enabled:
		clock.text = parse_time(OS.get_datetime())
		
		if Input.is_action_just_pressed("ui_left"):
			shift_menu(false)
		elif Input.is_action_just_pressed("ui_right"):
			shift_menu(true)

func shift_menu(forward):
	var previous_entry = get_node("Entrys").get_child(selected_entry)
	update_entry(false)

	if !forward:
		if selected_entry <= entrys.size()-1 && selected_entry >= 0:
			selected_entry -= 1
			if selected_entry < 0:
				selected_entry = entrys.size()-1
	else:
		if selected_entry < entrys.size()-1:
			selected_entry += 1
		else:
			selected_entry = 0
	var next_entry = get_node("Entrys").get_child(selected_entry)
	update_entry(true)
	#update_menu()

func update_entry(active):
	var entry = entrys[selected_entry]
	var options = menu[selected_entry]

	if active:
		SoundManager.play(0, self, cursor_sound)
		$Tween.interpolate_property(entry, "scale", Vector2(SCALE, SCALE), 
		Vector2(ACTIVE_SCALE, ACTIVE_SCALE), ANIMATION_SPEED, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(entry, "modulate", INACTIVE_TONE, 
		ACTIVE_TONE, ANIMATION_SPEED, Tween.TRANS_LINEAR)
		entryName.text = options["name"]

	else:
		$Tween.interpolate_property(entry, "scale", Vector2(ACTIVE_SCALE, ACTIVE_SCALE), 
		Vector2(SCALE, SCALE), ANIMATION_SPEED, Tween.TRANS_LINEAR)
		$Tween.interpolate_property(entry, "modulate", ACTIVE_TONE, 
		INACTIVE_TONE, ANIMATION_SPEED, Tween.TRANS_LINEAR)
	$Tween.start()
	
func parse_time(time):
	var hour = String(time.hour)
	hour = hour if hour.length() > 1 else "0" + hour
	var minute = String(time.minute)
	minute = minute if minute.length() > 1 else "0" + minute
	var weekday = parse_day(time.weekday)
	return hour + ":" + minute+ "\n" + weekday
	
func parse_day(day):
	match day:
		0:
			return "Sunday"
		1: 
			return "Monday"
		2:
			return "Tuesday"
		3:
			return "Wednesday"
		4:
			return "Thursday"
		5:
			return "Friday"
		6:
			return "Saturday"
	
func create_menu():
	if ENABLE_CLOCK:
		clock = Label.new()
		clock.text = parse_time(OS.get_datetime())
		clock.rect_position = get_viewport().get_visible_rect().position + Vector2(5,5)
		clock.add_font_override("font", dynamic_font)
		clock.add_color_override("font_color", MENU_TEXTCOLOR)
		clock.hide()
		add_child(clock)
	
	for index in menu.size():
		var entry = menu[index]
		var entrySprite = Sprite.new()
		entrySprite.texture = load(entry["icon"])
		entrySprite.position = get_viewport().get_visible_rect().size / 2
		if index == selected_entry:
			entryName = Label.new()
			entryName.text = entry["name"]
			entryName.rect_position = get_viewport().get_visible_rect().size / 2
			entryName.add_font_override("font", dynamic_font)
			entryName.add_color_override("font_color", MENU_TEXTCOLOR)
			entryName.hide()
			get_node("CenterContainer").add_child(entryName)

			entrySprite.modulate = ACTIVE_TONE
			entrySprite.scale = Vector2(ACTIVE_SCALE,ACTIVE_SCALE)
		else:
			entrySprite.modulate = INACTIVE_TONE
			entrySprite.scale = Vector2(SCALE,SCALE)
			
		entrySprite.hide()
		get_node("Entrys").add_child(entrySprite)
		entrys.append(entrySprite)

func show_menu():
	Time.freeze_time = true
	SoundManager.play(0, self, open_sound)
	color_before_tint = canvasModulate.color
	entryName.show()
	clock.show()
	$Tween.interpolate_property(entryName, "rect_scale", Vector2.ZERO, 
	Vector2.ONE, ANIMATION_SPEED, Tween.TRANS_LINEAR)
	var spacing = TAU / menu.size()
	for index in entrys.size():
		var entry = entrys[index]
		entry.show()
		var a = spacing * entry.get_position_in_parent() - BASE_ANGLE
		var dest = entry.position + Vector2(radius, 0).rotated(a)
		$Tween.interpolate_property(entry, "position",
		entry.position, dest, ANIMATION_SPEED,
		Tween.TRANS_BACK, Tween.EASE_OUT)
		if index == selected_entry:
			$Tween.interpolate_property(entry, "scale", Vector2(0.2, 0.2), 
			Vector2(ACTIVE_SCALE, ACTIVE_SCALE), ANIMATION_SPEED, Tween.TRANS_LINEAR)
		else:
			$Tween.interpolate_property(entry, "scale", Vector2(0.2, 0.2), 
			Vector2(SCALE, SCALE), ANIMATION_SPEED, Tween.TRANS_LINEAR)
			
	#var color_after_tint = color_before_tint
	#color_after_tint.a = BACKGROUND_OPACITY
	
	#$Tween.interpolate_property(canvasModulate, "color", color_before_tint, 
	#color_after_tint, ANIMATION_SPEED, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_completed")
	player = Paths.to_player()
	player.enabled = false

func hide_menu():
	Time.freeze_time = false
	SoundManager.play(0, self, quit_sound)
	$Tween.interpolate_property(entryName, "rect_scale", Vector2.ONE, 
	Vector2.ZERO, ANIMATION_SPEED, Tween.TRANS_LINEAR)
	
	for entry in entrys:
		$Tween.interpolate_property(entry, "position", entry.position,
				get_viewport().get_visible_rect().size / 2, ANIMATION_SPEED, Tween.TRANS_BACK, Tween.EASE_IN)
		$Tween.interpolate_property(entry, "scale", null,
				Vector2(0.2, 0.2), ANIMATION_SPEED, Tween.TRANS_LINEAR)
	#$Tween.interpolate_property(canvasModulate, "color", canvasModulate.color, 
	#color_before_tint, ANIMATION_SPEED, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_completed")
	for entry in entrys:
		entry.hide()
	entryName.hide()
	clock.hide()
	player = Paths.to_player()
	player.enabled = true
