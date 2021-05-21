extends MovementComponent
class_name NPCMovementComponent

enum MovementType {
	STATIC,
	RANDOM_TURN,
	RANDOM_WALK,
	SINGLE_MOVEMENT_HORIZONTAL,
	SINGLE_MOVEMENT_VERTICAL
}

var movement_type = MovementType.STATIC
var max_movement_delay = 127
var max_steps = 4

var movement_delay = 0

var spawn_position = Vector2.ZERO
var steps_till_bounds = 8

var rng = RandomNumberGenerator.new()

func _ready():
	._ready()
	if movement_type == MovementType.RANDOM_TURN:
		can_only_turn = true
	spawn_position = initial_position
	
func update(delta):
	.update(delta)
	if movement_locked == false:
		updateMovementBehaviour()

func updateMovementBehaviour():
	if debug:
		Log.trace(self, "Movement", "Entity movement type is %d and movement_delay is %d" % [movement_type, movement_delay])
	
	movement_delay -= 1
	if	movement_delay <= 0:
		match movement_type:
			MovementType.STATIC:
				pass
			MovementType.RANDOM_TURN:
				var random_direction = int(rng.randf_range(0, 3))
				if	facing_direction != random_direction:
					turn(random_direction)
			MovementType.RANDOM_WALK:
				var random_direction = int(rng.randf_range(0, 3))
				var random_steps = int(rng.randf_range(0, max_steps))
				if is_npc_inbound(random_direction, random_steps):
					walk(random_direction, random_steps)
			MovementType.SINGLE_MOVEMENT_HORIZONTAL:
				var random_direction = int(rng.randf_range(0, 1))
				var random_steps = int(rng.randf_range(0, max_steps))
				if is_npc_inbound(random_direction, random_steps):
					walk(random_direction, random_steps)
			MovementType.SINGLE_MOVEMENT_VERTICAL:
				var random_direction = int(rng.randf_range(2, 3))
				var random_steps = int(rng.randf_range(0, max_steps))
				if is_npc_inbound(random_direction, random_steps):
					walk(random_direction, random_steps)
			_:
				Log.error(self, "Movement", "Entity movement type is invalid, direction = %s" %movement_type)
		rng.randomize()
		movement_delay = rng.randf_range(0, max_movement_delay)

func is_npc_inbound(direction, steps) -> bool:
	# check if npc is still in reach of spawn_position
	# and if he colides he should move in the opposite direction for the next step
	var desired_step: Vector2 = direction_to_vector(direction) * (TILE_SIZE * steps) / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()
	if !ray.is_colliding():
		var area : Rect2 = Rect2(spawn_position.x, spawn_position.y, 
								steps_till_bounds * (TILE_SIZE / 2), 
								steps_till_bounds * (TILE_SIZE / 2)
							)
		var desired_position: Vector2 = entity.position + desired_step
		var is_in_bounds = area.has_point(desired_position)
		return is_in_bounds
	else:
		return true

func startRunning():
	is_running = true

func stopRunning():
	is_running = false

func turn(direction: int):
	event_processing += 1

	match(direction):
		FacingDirection.UP:
			movesQueue.push_front(Vector2.UP)
		FacingDirection.DOWN:
			movesQueue.push_front(Vector2.DOWN)
		FacingDirection.LEFT:
			movesQueue.push_front(Vector2.LEFT)
		FacingDirection.RIGHT:
			movesQueue.push_front(Vector2.RIGHT)
		_:
			Log.error(self, "Movement", "Entity turn direction is invalid, direction = %s" %direction)
			event_processing -= 1


func walk(direction: int, steps: int):
	var direction_vector = direction_to_vector(direction)
	if direction_vector != Vector2.ZERO:
		movesQueue.push_front(direction_vector)
		event_processing += 1
		for i in range(steps):
			movesQueue.push_front(direction_vector)
			event_processing += 1


func direction_to_vector(direction: int):
	match(direction):
		FacingDirection.UP:
			return Vector2.UP
		FacingDirection.DOWN:
			return Vector2.DOWN
		FacingDirection.LEFT:
			return Vector2.LEFT
		FacingDirection.RIGHT:
			return Vector2.RIGHT
		_:
			Log.error(self, "Movement", "Direction is invalid, direction = %s" %direction)
			return Vector2.ZERO

func vector_to_direction(vector: Vector2):
	match(vector):
		Vector2.UP:
			return FacingDirection.UP
		Vector2.DOWN:
			return FacingDirection.DOWN
		Vector2.LEFT:
			return FacingDirection.LEFT
		Vector2.RIGHT:
			return FacingDirection.RIGHT
		_:
			Log.error(self, "Movement", "Cant convert invalid vector to direction, vector = %s" %vector)
			return FacingDirection.DOWN
