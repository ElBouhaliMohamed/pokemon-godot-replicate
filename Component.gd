extends Node
class_name Component

onready var entity: Entity = get_parent()
export(bool) var enabled setget set_enabled
export(String) var comp_name = "" setget, _get_comp_name
export(bool) var debug = false

func _init(_comp_name:String) -> void:
	self.comp_name = _comp_name

func _ready() -> void:	
	entity.add_component(comp_name, self)
	add_to_group(Groups.COMPONENTS)

func disable() -> void:
	enabled = false
	set_process(false)
	Log.trace(self, "disable", "Component %s has been disabled" %comp_name)

func enable() -> void:
	enabled = true
	set_process(true)
	Log.trace(self, "enable", "Component %s has been enabled" %comp_name)

func set_enabled(val: bool) -> void:
	if val == false:
		disable()
	elif val == true:
		enable()

func _get_comp_name() -> String:
		return comp_name

func process(delta) -> void:
	if enabled:
		#if debug:
			#Log.trace(self, "processing", "Component %s is being processed" %comp_name)
		update(delta)
		
func update(delta):
	pass
	
