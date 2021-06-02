extends Command
class_name ChangeScene

export(String, FILE) var next_scene_path

func _ready():
	command_name = "ChangeScene"
	assert(next_scene_path)

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	if debug:
		Log.trace(self, "ChangeScene", "Changing scene to %s" %[next_scene_path])
	var SceneManager = get_node(NodePath("/root/Game/SceneManager"))
	yield(SceneManager.change_scene(next_scene_path),"completed")
	finished()
