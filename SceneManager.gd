extends Node

onready var anim = $CanvasLayer/Fader/AnimationPlayer
onready var label = $CanvasLayer/Fader/Label

func change_scene(next_scene, params=[]):
	"""
	Changes scene with a transition.
	You can hold the fade back in transition if desired until
	the next scene is in a state that is considered ready
	"""
	get_tree().paused = true
	
	anim.play_backwards("Fade")
	yield(anim, "animation_finished")
	label.visible = true
	 
	var current_scene = $CurrentScene.get_child(0)
	if current_scene.has_method("_teardown"):
		var state = current_scene._teardown()
		if state and state is GDScriptFunctionState:
			yield(state, "completed")
	
	current_scene.queue_free()
	$CurrentScene.add_child(load(next_scene).instance())
	#yield(get_tree(), "idle_frame")
	
	current_scene = $CurrentScene.get_children().back()
	
	if current_scene.has_method("_setup"):
		var state = current_scene._setup(params)
		if state and state is GDScriptFunctionState:
			yield(state, "completed")
		
	label.visible = false
	anim.play("Fade")
	yield(anim, "animation_finished")
	
	get_tree().paused = false
	
