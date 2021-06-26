extends AnimatedSprite

var grass_sound = load("res://Assets/Sounds/se_step_grass.wav")

func _ready():
	SoundManager.play(0,self, grass_sound)
	frame = 0
	playing = true

func _on_GrassStepEffect_animation_finished():
	queue_free()
