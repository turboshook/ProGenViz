@tool
extends Node
class_name SoundQueue

@export_range(1, 12) var _player_count: int = 1
@export_range(0.0, 1.0, 0.01) var _random_pitch_scale_range: float = 0.0
var _base_pitch_scale: float = 1.0
var _stream_players: Array[AudioStreamPlayer] = []
var _stream_player_index: int = 0

func _ready() -> void:
	if get_child_count() == 0:
		push_warning("No child AudioStreamPlayer found, this SoundQueue will not function.")
		return
	elif not get_child(0) is AudioStreamPlayer:
		push_warning("Child node is not instance of AudioStreamPlayer, this SoundQueue will not function.")
		return
	
	var stream_player: AudioStreamPlayer = get_child(0)
	stream_player.set_bus("SFX")
	_base_pitch_scale = stream_player.pitch_scale
	_stream_players.append(stream_player)
	for _i: int in range(_player_count - 1):
		var duplicate_player: AudioStreamPlayer = stream_player.duplicate()
		add_child(duplicate_player)
		_stream_players.append(duplicate_player)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_child_count() == 0: warnings.append("Expected one AudioStreamPlayer child.")
	elif not get_child(0) is AudioStreamPlayer: warnings.append("Expected first child node to be instance of AudioStreamPlayer.")
	if get_child_count() > 1: warnings.append("AudioStreamPlayer children past index 0 will not be played.")
	return warnings

func play() -> void:
	# intentionally skip a stream playback rather than cut it off
	if _stream_players[_stream_player_index].is_playing(): return
	var pitch_scale: float = _base_pitch_scale
	if _random_pitch_scale_range != 0.0:
		pitch_scale = randf_range(
			pitch_scale - abs(_random_pitch_scale_range), 
			pitch_scale + abs(_random_pitch_scale_range)
		)
	if pitch_scale <= 0.0: pitch_scale = _stream_players[_stream_player_index].pitch_scale # messy accounting for negative pitch
	_stream_players[_stream_player_index].pitch_scale = pitch_scale
	_stream_players[_stream_player_index].play()
	_stream_player_index += 1
	_stream_player_index %= _stream_players.size()
