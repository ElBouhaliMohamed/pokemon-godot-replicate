extends Command
class_name Dialog

export(String) var dialog

onready var DialogPlayer = get_node(NodePath("/root/Game/Dialog_Player"))

func _ready():
	command_name = "Dialog"
	assert(dialog)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	if debug:
		Log.trace(self, "Dialog", "Showing %s dialog" %[dialog])
	DialogPlayer.play_dialog(dialog)
	yield(DialogPlayer, "dialog_finished")
	if debug:
		Log.trace(self, "Dialog", "Finished %s dialog" %[dialog])
	finished()
