extends Component
class_name ScriptComponent

onready var ray = get_owner().get_node("RayCast2D")
onready var player = get_owner()

var script_running = false

func _init().("Script"):
	pass

func update(delta):
	if script_running == false && Input.is_action_just_pressed("ui_accept") && ray.is_colliding():
		var entity : Entity = ray.get_collider()
		var event = entity.entity_event
		if event != null:
			script_running = true
			lock_entities_and_player([entity.entity_id])
			event.run(player, get_entities())
			yield(event, "finished_event")
			unlock_entities_and_player([entity.entity_id])
			script_running = false

func get_entities():
	return get_tree().get_nodes_in_group(Groups.ENTITIES)

func lock_entities_and_player(scriptTargets: Array):
	player.get_component("Movement")._set_movement_locked(true)

	for entity in get_entities():
		if entity != null:
			if scriptTargets.find(entity.entity_id) == -1:
				var entity_movementComponent : MovementComponent = entity.get_component("Movement")
				entity_movementComponent._set_movement_locked(true)

func unlock_entities_and_player(scriptTargets: Array):
	player.get_component("Movement")._set_movement_locked(false)

	for entity in get_entities():
		if scriptTargets.find(entity.entity_id) == -1:
			var entity_movementComponent : MovementComponent = entity.get_component("Movement")
			entity_movementComponent._set_movement_locked(false)
