extends Node

var flags : Dictionary

func _ready():
	# load from savefile
	pass

func lookup(name : String):
	if flags.has(name):
		return flags[name]
	else:
		return null

func add_flag(name: String, triggered: bool = false):
	flags[name] = triggered
	
func trigger_flag(name: String):
	flags[name] = true
	
func reset_flag(name: String):
	flags[name] = false
