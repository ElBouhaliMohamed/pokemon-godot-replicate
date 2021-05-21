extends Node2D
class_name Entity

enum EnitityType {
	Undefined,
	Player,
	NPC,
	StaticObject
}

export(Texture) var entity_walking_texture
export(Texture) var entity_running_texture
var entity_event: Event

export(bool) var enable_on_spawn = false
export var entity_type = EnitityType.Undefined

export var movement_type = 0
export var max_movement_delay = 127
export var max_steps = 4
export var steps_till_bounds = 8

var enabled = false setget set_enabled

onready var entity_id: int = self.get_instance_id()

export var entity_name: String = ""

var components: Dictionary = {}

var state: PlayerState = PlayerState.new()

func _ready() -> void:
	entity_event = get_node_or_null("Event")
	
	if entity_type == 1 || entity_type == 2:
		get_node("WalkingSprite").texture = entity_walking_texture
		get_node("RunningSprite").texture = entity_running_texture

		var movementComponent = get_node("MovementComponent")
		movementComponent.movement_type = movement_type
		movementComponent.max_movement_delay = max_movement_delay
		movementComponent.max_steps = max_steps
		movementComponent.steps_till_bounds = steps_till_bounds
		
	
	if enable_on_spawn:
		enabled = true
	add_to_group(Groups.ENTITIES)
	if !enabled: #disable all components if entity is disabled
		set_enabled(enabled)

func _physics_process(delta):
	if enabled:
		process_components(delta)

func process_components(delta):
	for comp in components.values():
		if comp.enabled == true:
			comp.process(delta)

func add_component(_name: String, _comp: Node) -> void:
	# Add error checking here.
	components[_name] = _comp

func get_component(_name: String) -> Node:
	if components.has(_name):
		return components[_name]
	else:
		return null
func disable() -> void:
	for comp in components.values():
		comp.disable()
	Log.trace(self, "disable", "Entity id:%s, name:%s has been disabled" 
			%[entity_id, entity_name])
	enabled = false
	
func enable() -> void:
	for comp in components.values():
		comp.enable()
	Log.trace(self, "enable", "Entity id:%s, name:%s has been enabled" 
			%[entity_id, entity_name])
	enabled = true

func set_enabled(val: bool) -> void:
	if val:
		enable()
	else:
		disable()
