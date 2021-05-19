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
var percent_moved_to_next_tile = 0.0

onready var ray = get_owner().get_node("RayCast2D")
onready var anim_tree = get_owner().get_node("AnimationTree")

enum FacingDirection { LEFT, RIGHT, UP, DOWN }
var facing_direction = FacingDirection.DOWN

var movesQueue = []
var nextMove_direction = Vector2(0,0)

func _init().("MovementComponent"):
	pass

func _ready() -> void:
	initial_position = entity.position

func update(delta):
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
		new_facing_direction = FacingDirection.LEFT
	elif nextMove_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif nextMove_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif nextMove_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	
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
			else:
				initial_position = entity.position
				is_moving = true
	else:
		entity.state.set_state(PlayerStates.IDLE)

func move(delta):
	var desired_step: Vector2 = nextMove_direction * TILE_SIZE / 2
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
			is_running = false
			nextMove_direction = Vector2.ZERO
			emit_signal("entity_stopped_signal")
		else:
			entity.position = initial_position + (nextMove_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false
		is_running = false
