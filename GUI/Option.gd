extends Label

signal clicked(slot)

var slot
var active : bool

func _process(delta):
	if active && Input.is_action_just_pressed("ui_accept"):
		emit_signal("clicked", slot)
