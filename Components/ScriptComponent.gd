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
			ScriptMisc.lock_entities_and_player(Paths.to_entities(), player)
			event.run(player, Paths.to_entities())
			yield(event, "finished_event")
			ScriptMisc.unlock_entities_and_player(Paths.to_entities(), player)
			script_running = false
