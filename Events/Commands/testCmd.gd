extends Command
class_name TestCmd

func _ready():
	command_name = "Test"

func run(player: Entity, entities: Array) -> void:
	.run(player,entities)
	Log.trace(self, "Test", "This is a test command running before the delay")
	yield(get_tree().create_timer(5.0), "timeout")
	Log.trace(self, "Test", "This is a test command running after the delay")
	finished()
