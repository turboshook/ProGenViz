extends Control
class_name AppSettingsMenu

@onready var volume_slider: HSlider = $PanelContainer/MarginContainer/SettingsContainer/SFXVolumeContainer/VolumeSlider
@onready var rng_seed_edit: LineEdit = $PanelContainer/MarginContainer/SettingsContainer/RandomSeedContainer/RNGSeedEdit

func _ready() -> void:
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	rng_seed_edit.text_submitted.connect(_on_rng_seed_edit_text_submitted)

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)

func _on_rng_seed_edit_text_submitted(new_text: String) -> void:
	if new_text == "": randomize()
	elif new_text.is_valid_int(): seed(int(new_text))
	else: seed(new_text.hash())
	
