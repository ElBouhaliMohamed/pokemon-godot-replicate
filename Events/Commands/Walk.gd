extends Command
class_name Walk

export(int) var direction
export(int) var steps
export(NodePath) var entity_path 
onready var entity = get_node(entity_path)

func _ready():
	command_name = "Walk"
	assert(entity)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	var movementComponent = entity.get_component("Movement")
	if debug:
		Log.trace(self, "Walk", "Entity %s walking %s steps with direction %s" %[entity.entity_id, steps, direction])
	movementComponent.walk(direction, steps)
	while movementComponent.event_processing > 0:
		yield(get_tree(),"idle_frame")
	if debug:
		Log.trace(self, "Walk", "Entity %s finished walking %s steps with direction %s" %[entity.entity_id, steps, direction])
	finished()
