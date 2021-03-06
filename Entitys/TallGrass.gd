extends Node2D

onready var anim_player = $AnimationPlayer
const grass_overlay_texture = preload("res://Assets/Grass/stepped_tall_grass.png")
const GrassStepEffect = preload("res://VisualEffects/GrassStepEffect.tscn")
var grass_overlay: TextureRect = null


var player_inside: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = Paths.to_player()
	player.get_node("MovementComponent").connect("entity_moving_signal", self, "entity_exiting_grass")
	player.get_node("MovementComponent").connect("entity_stopped_signal", self, "entity_in_grass")

func entity_exiting_grass():
	player_inside = false
	if is_instance_valid(grass_overlay):
		grass_overlay.queue_free()
	
func entity_in_grass():
	if player_inside == true:
		var grass_step_effect = GrassStepEffect.instance()
		grass_step_effect.position = position
		get_tree().current_scene.add_child(grass_step_effect)
		
		
		grass_overlay = TextureRect.new()
		grass_overlay.texture = grass_overlay_texture
		grass_overlay.rect_position = position
		get_tree().current_scene.add_child(grass_overlay)


func _on_Area2D_body_entered(body):
	player_inside = true
	anim_player.play("Stepped")
