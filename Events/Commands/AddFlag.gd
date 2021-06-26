extends Command
class_name AddFlag

export(String) var flag_name
export(bool) var triggered = false

func _ready():
	command_name = "AddFlag"
	assert(flag_name)

func run(player: Entity, entities: Array) -> void:
	.run(player,entities)
	Flags.add_flag(flag_name, triggered)
	Log.trace(self, "Flag", "Set flag %s to %s" %[flag_name, triggered])
	finished()
