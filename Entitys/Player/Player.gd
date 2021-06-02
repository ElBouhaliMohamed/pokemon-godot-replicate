extends Entity

func _ready():
	._ready()
	get_node("WalkingSprite").texture = entity_walking_texture
	get_node("RunningSprite").texture = entity_running_texture

	var movementComponent = get_component("Movement")
	movementComponent.movement_type = movement_type
	movementComponent.max_movement_delay = max_movement_delay
	movementComponent.max_steps = max_steps
	movementComponent.steps_till_bounds = steps_till_bounds
