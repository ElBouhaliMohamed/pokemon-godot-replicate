extends Node2D
class_name Map

export(bool) var debug = false
export(String) var map_name = ""

func _setup(params):
	if debug:
		Log.trace(self, "_setup", "Setting up %s" %map_name)
	# run map events
	var player = Paths.to_player()
	var entities = Paths.to_entities()
	var map_events = get_tree().get_nodes_in_group(Groups.MAP_EVENTS)
	for map_event in map_events:
		map_event.lock_entities_and_player(entities)
		map_event.run(player, entities)
		yield(map_event, "finished_event")
		map_event.unlock_entities_and_player(entities)

func _teardown():
	if debug:
		Log.trace(self, "_teardown", "Tear down %s" %map_name)
	pass
