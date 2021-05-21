extends Command
class_name Run

export(int) var direction
export(int) var steps
export(NodePath) var entity_path 
onready var entity = get_node(entity_path)

func _ready():
	command_name = "Run"
	assert(entity)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	var movementComponent = entity.get_node("MovementComponent")
	movementComponent.is_running = true
	if debug:
		Log.trace(self, "Run", "Entity %s runs %s steps with direction %s" %[entity.entity_id, steps, direction])
	movementComponent.walk(direction, steps)
	while movementComponent.event_processing > 0:
		yield(get_tree(),"idle_frame")
	movementComponent.is_running = false
	if debug:
		Log.trace(self, "Run", "Entity %s finished running %s steps with direction %s" %[entity.entity_id, steps, direction])
	finished()
