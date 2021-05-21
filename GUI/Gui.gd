extends CanvasLayer

onready var msg = get_node("MessageBox")
onready var options = get_node("Options")
onready var menu = get_node("MainMenu")

func _ready():
	menu.connect("option", self, "_on_menu_options")

func show_msg(text, obj = null, sig=""):
	msg.show_msg(text,obj,sig)

func show_options():
	options.show()
	options.set_process(true)
	yield(options,"exit")
	options.set_process(false)

func show_menu():
	menu.show()
	menu.set_process(true)
	yield(menu,"exit")
	menu.set_process(false)

func is_visible():
	return msg.is_visible() || options.is_visible() || menu.is_visible()

func _on_menu_options():
	menu.hide()
	menu.set_process(false)
	show_options()
	yield(options, "exit")
	menu.show()
	menu.set_process(true)
