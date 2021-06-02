extends Command
class_name FadeScreen

export(bool) var fade_in

func _ready():
	command_name = "FadeScreen"

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	
	if debug:
		var type = "in" if fade_in == true else "out"
		Log.trace(self, "FadeScreen", "Fading screen %s" %type)
		
	var anim = get_node(NodePath("/root/Game/SceneManager/CanvasLayer/Fader/AnimationPlayer"))
	if fade_in:
		anim.play("Fade")
		yield(anim, "animation_finished")
	else:
		anim.play_backwards("Fade")
		yield(anim, "animation_finished")
		
	if debug:
		var type = "in" if fade_in == true else "out"
		Log.trace(self, "FadeScreen", "Done Fading screen %s" %type)
		
	finished()
