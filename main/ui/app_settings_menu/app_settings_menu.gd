extends Control
class_name AppSettingsMenu

@onready var volume_slider: HSlider = $PanelContainer/MarginContainer/SettingsContainer/SFXVolumeContainer/VolumeSlider

func _ready() -> void:
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)
