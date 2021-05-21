extends Component
class_name ScriptComponent

onready var ray = get_owner().get_node("RayCast2D")
onready var player = get_owner()
onready var entities = get_tree().get_nodes_in_group("Entities")

var script_running = false

func _init().("ScriptComponent"):
	pass

func update(delta):
	if script_running == false && Input.is_action_pressed("ui_accept") && ray.is_colliding():
		var entity : Entity = ray.get_collider()
		var event = entity.entity_event
		if event != null:
			script_running = true
			lock_entities_and_player([entity.entity_id])
			event.run(player, entities)
			yield(event, "finished_event")
			unlock_entities_and_player([entity.entity_id])
			script_running = false

func lock_entities_and_player(scriptTargets: Array):
	player.get_node("MovementComponent").movement_locked = true

	for entity in entities:
		if scriptTargets.find(entity.entity_id) == -1:
			var entity_movementComponent : MovementComponent = entity.get_node("MovementComponent")
			entity_movementComponent.movement_locked = true

func unlock_entities_and_player(scriptTargets: Array):
	player.get_node("MovementComponent").movement_locked = false

	for entity in entities:
		if scriptTargets.find(entity.entity_id) == -1:
			var entity_movementComponent : MovementComponent = entity.get_node("MovementComponent")
			entity_movementComponent.movement_locked = false
