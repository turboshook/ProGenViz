extends Node

@onready var _bgm_stream_player: AudioStreamPlayer = $BGMStreamPlayer
var _sounds: Dictionary = {}

func _ready() -> void:
	for child: Node in get_children():
		if !(child is SoundQueue) and !(child is SoundPool): continue
		_sounds[child.name.to_lower()] = child

func play_bgm(bgm_stream: AudioStream) -> void:
	if _bgm_stream_player.is_playing():
		stop_bgm()
		await get_tree().create_timer(0.25).timeout
	_bgm_stream_player.stream = bgm_stream
	_bgm_stream_player.play()
	_bgm_stream_player.volume_linear = 0.2 # temp

func stop_bgm(fade_out_time: float = 0.25) -> void:
	if not _bgm_stream_player.is_playing(): return
	var volume_down_tween: Tween = create_tween()
	volume_down_tween.tween_property(_bgm_stream_player, "volume_linear", 0.0, fade_out_time)
	await volume_down_tween.finished

func play_sound(sound_name: String) -> void:
	if not _sounds.has(sound_name): return
	_sounds[sound_name].play()
