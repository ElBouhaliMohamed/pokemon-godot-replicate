extends NPCMovementComponent
class_name PlayerMovementComponent

func process_queue():
	var input_direction = Vector2.ZERO
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	if input_direction != Vector2.ZERO:
		if Input.is_action_pressed("ui_shift"):
			self.is_running = true
		else:
			self.is_running = false
			
		self.movesQueue.push_front(input_direction)

func finished_turning():
	.finished_turning()
