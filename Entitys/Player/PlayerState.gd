extends Reference
class_name PlayerState

var state: int = PlayerStates.IDLE setget set_state
var changed = false setget , has_changed

func get_state():
	return self.state
	
func set_state(val):
	if val != state:
		changed = true
		
	state = val

func has_changed():
	if changed:
		changed = false
		return true
	else:
		return false
