extends Command
class_name ResetFlag

export(String) var flag_name

func _ready():
	command_name = "ResetFlag"
	assert(flag_name)

func run(player: Entity, entities: Array) -> void:
	.run(player,entities)
	Flags.reset_flag(flag_name)
	Log.trace(self, "Flag", "Reset flag %s" %flag_name)
	finished()
