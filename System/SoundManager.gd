extends Node

enum Type {
	NON_POSITIONAL,
	POSITIONAL_2D,
}

func play(type: int, parent: Node, stream: AudioStream, name: String = "", volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var audio_stream_player: Node
	match type:
		Type.NON_POSITIONAL:
			audio_stream_player = AudioStreamPlayer.new()
		Type.POSITIONAL_2D:
			audio_stream_player = AudioStreamPlayer2D.new()
			
	if not name.empty():
		if parent.has_node(name):
			return
		audio_stream_player.name = name

	parent.add_child(audio_stream_player)
	audio_stream_player.bus = "Effects"
	audio_stream_player.stream = stream
	audio_stream_player.volume_db = volume_db
	audio_stream_player.pitch_scale = pitch_scale
	audio_stream_player.play()
	audio_stream_player.connect("finished", audio_stream_player, "queue_free")
