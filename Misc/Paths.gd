extends Node

func to_camera():
	return get_node("/root/Game/SceneManager/CurrentScene").get_children().back().find_node("Camera2D")

func to_player():
	return get_node("/root/Game/SceneManager/CurrentScene").get_children().back().find_node("Player")

func to_weather_manager():
	return get_node("/root/Game/SceneManager/CurrentScene").get_children().back().find_node("Weather")

func to_scene_manager():
	return get_node("/root/Game/SceneManager")

func to_entities():
	return get_tree().get_nodes_in_group(Groups.ENTITIES)
