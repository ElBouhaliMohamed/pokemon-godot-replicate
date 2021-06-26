extends Node
class_name Event

signal finished_event

func run(player, entities):
	for cmd in get_children():
		cmd.call_deferred("run", player, entities)
		yield(cmd, "finished_command")
	emit_signal("finished_event")
