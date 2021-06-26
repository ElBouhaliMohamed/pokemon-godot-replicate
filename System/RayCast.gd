extends RayCast2D

export(bool) var debug = false

func _ready():
	if debug:
		set_process(true)

func _process(delta):
	update()

func _draw():
	draw_line(position, position + cast_to, Color(255, 0, 0), 1)
