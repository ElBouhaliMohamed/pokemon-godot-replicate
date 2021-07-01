extends Component
class_name MovementComponent

const TILE_SIZE = 16

signal entity_moving_signal
signal entity_stopped_signal

export(float) var walk_speed = 4.0
export(float) var running_speed = 8.0
export(float) var biking_speed = 16.0
export(bool) var can_bike = false

var current_speed = walk_speed
var initial_position = Vector2(0, 0)
var is_moving = false
var is_running = false
var can_only_turn = false
var movement_locked = false setget _set_movement_locked, _get_movement_locked
var is_in_cutscene = false
var percent_moved_to_next_tile = 0.0

onready var ray = get_owner().get_node("RayCast2D")
onready var anim_tree = get_owner().get_node("AnimationTree")

var FacingDirections = Enums.FacingDirections
var PlayerStates = Enums.PlayerStates

var facing_direction = FacingDirections.DOWN

var movesQueue = []
var nextMove_direction = Vector2(0,0)
var event_processing = 0

var bump_sound = load("res://Assets/Sounds/Player bump.wav")

func _init().("Movement"):
	pass

func _ready() -> void:
	initial_position = entity.position

func _set_movement_locked(new_value):
	movement_locked = new_value

func _get_movement_locked():
	return movement_locked

func update(delta):
	if movement_locked == false || is_in_cutscene == true || (entity.state.get_state() == PlayerStates.WALKING || entity.state.get_state() == PlayerStates.RUNNING):
		if entity.state.get_state() == PlayerStates.TURNING:
			return
		elif is_moving == false:
			process_entity_movement_input()
		elif nextMove_direction != Vector2.ZERO:
			if entity.state.get_state() == PlayerStates.RUNNING:
				current_speed = running_speed
			else:
				current_speed = walk_speed
			
			move(delta)
		else:
			is_moving = false
		
func need_to_turn():
	var new_facing_direction
	if nextMove_direction.x < 0:
		new_facing_direction = FacingDirections.LEFT
	elif nextMove_direction.x > 0:
		new_facing_direction = FacingDirections.RIGHT
	elif nextMove_direction.y < 0:
		new_facing_direction = FacingDirections.UP
	elif nextMove_direction.y > 0:
		new_facing_direction = FacingDirections.DOWN
	
	if !can_only_turn:
		if facing_direction != new_facing_direction:
			facing_direction = new_facing_direction
			return true
		facing_direction = new_facing_direction
		return false
	else:
		facing_direction = new_facing_direction
		return true

func finished_turning():
	entity.state.set_state(PlayerStates.IDLE)
	var desired_step: Vector2 = calc_desired_step(nextMove_direction, 1)
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
func process_queue():
	pass

func process_entity_movement_input():
	process_queue()

	if !movesQueue.empty():
		nextMove_direction = movesQueue[0]
		movesQueue.remove(0)

		if debug:
			Log.trace(self, "Movement", "%s has been removed from the Queue" %nextMove_direction)
			
		if nextMove_direction != Vector2.ZERO:
			entity.state.set_state(PlayerStates.WALKING)
			
			if is_running == true:
				entity.state.set_state(PlayerStates.RUNNING)
			
			anim_tree.set("parameters/Idle/blend_position", nextMove_direction)
			anim_tree.set("parameters/Walk/blend_position", nextMove_direction)
			anim_tree.set("parameters/Run/blend_position", nextMove_direction)
			anim_tree.set("parameters/Turn/blend_position", nextMove_direction)
			
			if need_to_turn():
				if is_running == false:
					entity.state.set_state(PlayerStates.TURNING)
				if event_processing > 0:
					event_processing -= 1

			else:
				initial_position = entity.position
				is_moving = true
	else:
		entity.state.set_state(PlayerStates.IDLE)

func move(delta):
	var desired_step: Vector2 = calc_desired_step(nextMove_direction, 1)
	ray.cast_to = desired_step
	ray.force_raycast_update()
	if !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("entity_moving_signal")
			
		percent_moved_to_next_tile += current_speed * delta
		
		if percent_moved_to_next_tile >= 1.0:
			entity.position = initial_position + (nextMove_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			nextMove_direction = Vector2.ZERO
			if event_processing > 0:
				event_processing -= 1
			emit_signal("entity_stopped_signal")
		else:
			entity.position = initial_position + (nextMove_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		if entity is Player:
			SoundManager.play(0, self, bump_sound, "bump")
		is_moving = false
		if event_processing > 0:
			event_processing -= 1

# helper functions
func calc_desired_step(direction: Vector2, steps: int, scale: int = 2):
	return direction * (TILE_SIZE * steps) / scale
