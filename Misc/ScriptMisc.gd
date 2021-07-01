extends Reference
class_name ScriptMisc

static func lock_entities_and_player(scriptTargets: Array, player: Player):
	player.get_component("Movement")._set_movement_locked(true)

	for entity in Paths.to_entities():
		if entity != null:
			if scriptTargets.find(entity.entity_id) == -1:
				var entity_movementComponent : MovementComponent = entity.get_component("Movement")
				entity_movementComponent._set_movement_locked(true)

static func unlock_entities_and_player(scriptTargets: Array, player: Player):
	player.get_component("Movement")._set_movement_locked(false)

	for entity in Paths.to_entities():
		if scriptTargets.find(entity.entity_id) == -1:
			var entity_movementComponent : MovementComponent = entity.get_component("Movement")
			entity_movementComponent._set_movement_locked(false)
			