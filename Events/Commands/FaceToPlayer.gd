extends Command
class_name FaceToPlayer

export(NodePath) var entity_path 
onready var entity = get_node(entity_path)

func _ready():
	command_name = "FaceToPlayer"
	assert(entity)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	var movementComponent = entity.get_component("Movement")
	var direction_vector = entity.position.direction_to(player.position)
	var direction = movementComponent.vector_to_direction(direction_vector)
	if debug:
		Log.trace(self, "FaceToPlayer", "Facing entity %s to player with direction %s" %[entity.entity_id, direction])
	movementComponent.turn(direction)
	while movementComponent.event_processing > 0:
		yield(get_tree(),"idle_frame")
	finished()
