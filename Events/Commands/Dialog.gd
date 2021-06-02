extends Command
class_name Dialog

export(String) var dialog

func _ready():
	command_name = "Dialog"
	assert(dialog)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	if debug:
		Log.trace(self, "Dialog", "Showing %s dialog" %[dialog])
	MessageBox.show_message(dialog, false)
	yield(MessageBox, "dialog_finished")
	if debug:
		Log.trace(self, "Dialog", "Finished %s dialog" %[dialog])
	finished()
