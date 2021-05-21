extends Node
class_name Event

signal finished_event

# enum EventType {
#     Undefined,
#     Map,
#     Area,
#     NPC
# }

func run(player, entities):
	for cmd in get_children():
		cmd.run(player, entities)
		yield(cmd, "finished_command")
	emit_signal("finished_event")
