extends Command
class_name TriggerFlag

export(String) var flag_name

func _ready():
	command_name = "TriggerFlag"
	assert(flag_name)

func run(player: Entity, entities: Array) -> void:
	.run(player,entities)
	Flags.trigger_flag(flag_name)
	Log.trace(self, "Flag", "Triggered flag %s" %flag_name)
	finished()
