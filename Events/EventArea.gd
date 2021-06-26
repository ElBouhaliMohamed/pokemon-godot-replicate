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
		player.get_component("Movement")._set_movement_locked(true)
		run(player, entities)
		yield(self, "finished_event")
		Flags.trigger_flag(flag_name)
		script_running = false
		player.get_component("Movement")._set_movement_locked(false)

func lock_entities_and_player(scriptTargets: Array):
	player.get_component("Movement")._set_movement_locked(true)

	for entity in Paths.to_entities():
		if entity != null:
			if scriptTargets.find(entity.entity_id) == -1:
				var entity_movementComponent : MovementComponent = entity.get_component("Movement")
				entity_movementComponent._set_movement_locked(true)

func unlock_entities_and_player(scriptTargets: Array):
	player.get_component("Movement")._set_movement_locked(false)

	for entity in Paths.to_entities():
		if scriptTargets.find(entity.entity_id) == -1:
			var entity_movementComponent : MovementComponent = entity.get_component("Movement")
			entity_movementComponent._set_movement_locked(false)
			


func run(player, entities):
	for cmd in $Script.get_children():
		cmd.call_deferred("run", player, entities)
		yield(cmd, "finished_command")
	emit_signal("finished_event")
