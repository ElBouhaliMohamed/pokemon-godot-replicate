extends Component
class_name AnimationComponent

onready var anim_tree = get_owner().get_node("AnimationTree")
onready var anim_state = anim_tree.get("parameters/playback")
onready var walkingSprite = get_owner().get_node("WalkingSprite")
onready var runningSprite = get_owner().get_node("RunningSprite")

func _ready():
	anim_tree.active = true

func _init().("Animation"):
	pass

func update(delta):
	match entity.state.get_state():
		PlayerStates.IDLE:
			anim_state.travel("Idle")
		PlayerStates.TURNING:
			anim_state.travel("Turn")
		PlayerStates.WALKING:
			anim_state.travel("Walk")
		PlayerStates.RUNNING:
			anim_state.travel("Run")

	enable_sprite()
	
	if debug:
		if entity.state.has_changed():
			Log.trace(self, "", "Entity State was changed to %s" %entity.state.get_state())

func enable_sprite():
	match(entity.state.get_state()):
		PlayerStates.RUNNING:
			walkingSprite.visible = false
			runningSprite.visible = true
		_:
			walkingSprite.visible = true
			runningSprite.visible = false
