extends Node
class_name Command

signal finished_command

var command_name = ""
export(bool) var debug = false

func run(player: Entity, entities: Array) -> void:
	if debug:
		Log.trace(self, "processing", "Component %s is being processed" %command_name)
	else:
		pass

func finished() -> void:
	emit_signal("finished_command")
