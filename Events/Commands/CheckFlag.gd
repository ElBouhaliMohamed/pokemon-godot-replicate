extends Command
class_name CheckFlag

export(String) var flag_name

onready var true_event = $True
onready var false_event = $False
onready var doesnt_exist_event = $DoesNotExist

func _ready():
	command_name = "CheckFlag"
	assert(flag_name)

func run(player: Entity, entities: Array):
	.run(player,entities)
	Log.trace(self, "Flag", "Check flag %s" %flag_name)
	var result = Flags.lookup(flag_name)
	if result != null:
		
		if result == true:
			Log.trace(self, "Flag", "Flag %s is true" %flag_name)
			true_event.run(player, entities)
			yield(true_event, "finished_event")
		else:
			Log.trace(self, "Flag", "Flag %s is false" %flag_name)
			false_event.run(player, entities)
			yield(false_event, "finished_event")
			
	else:
		doesnt_exist_event.run(player, entities)
		yield(doesnt_exist_event, "finished_event")
		Log.trace(self, "Flag", "Flag %s does not exist" %flag_name)
		
	finished()
