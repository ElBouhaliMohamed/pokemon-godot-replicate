extends Command
class_name CameraShake

export(int) var duration
export(int) var frequency
export(int) var amplitude
export(bool) var wait_till_finished

func _ready():
	command_name = "CameraShake"

func run(player: Entity, entites: Array) -> void:
	.run(player, entites)
	
	if debug:
		Log.trace(self, "CameraShake",
		"Camera shake with duration %d frequency %d amplitude %d" 
		%[duration, frequency, amplitude])
		
	var camera = Paths.to_camera()
	camera.shake(duration, frequency, amplitude)
	
	if wait_till_finished:
		yield(camera, "finished_shake")
	else:
		yield(get_tree(),"idle_frame")
		
	finished()
