extends Command
class_name Turn

export(int) var direction
export(NodePath) var entity_path 
onready var entity = get_node(entity_path)

func _ready():
	command_name = "Run"
	assert(entity)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	var movementComponent = entity.get_component("Movement")
	movementComponent.is_running = true
	if debug:
		Log.trace(self, "Run", "Entity %s turns to direction %s" %[entity.entity_id, direction])
	movementComponent.turn(direction)
	while movementComponent.event_processing > 0:
		yield(get_tree(),"idle_frame")
	movementComponent.is_running = false
	finished()
