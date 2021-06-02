extends Node2D
class_name Map

export(bool) var debug = false
export(String) var map_name = ""

func _setup(params):
	if debug:
		Log.trace(self, "_setup", "Setting up %s" %map_name)
	pass

func _teardown():
	if debug:
		Log.trace(self, "_teardown", "Tear down %s" %map_name)
	pass
