extends Area2D
class_name EventArea

signal finished_event

var script_running = false

enum type {
	TRIGGER_EVENT	
	MAP_EVENT
}

export(String) var flag_name
export(type) var event_type

var player

func _ready():
	assert(flag_name)

	if Flags.lookup(flag_name) == null:
		Flags.add_flag(flag_name)

	if event_type == type.TRIGGER_EVENT:
		self.connect("body_entered", self, "_body_entered")
	else:
		player = Paths.to_player()
		add_to_group(Groups.MAP_EVENTS)

func _body_entered(body):
	if body is Player && !Flags.lookup(flag_name):
		player = body
		script_running = true
		var entities = Paths.to_entities()
		ScriptMisc.lock_entities_and_player(Paths.to_entities(), player)
		run(player, entities)
		yield(self, "finished_event")
		Flags.trigger_flag(flag_name)
		script_running = false
		ScriptMisc.unlock_entities_and_player(Paths.to_entities(), player)



func run(player, entities):
	for cmd in $Script.get_children():
		cmd.call_deferred("run", player, entities)
		yield(cmd, "finished_command")
	emit_signal("finished_event")
