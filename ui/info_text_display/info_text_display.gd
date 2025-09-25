extends PanelContainer
class_name InfoTextDisplay

@onready var info_label: Label = $MarginContainer/InfoLabel
var visible_characters_tween: Tween

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func set_text(text: String) -> void:
	info_label.text = text
	if visible: _tween_visible_characters()

func _on_visibility_changed() -> void:
	if visible: _tween_visible_characters()

func _tween_visible_characters() -> void:
	if is_instance_valid(visible_characters_tween):
		visible_characters_tween.stop()
	info_label.visible_ratio = 0.0
	visible_characters_tween = create_tween()
	visible_characters_tween.tween_property(
		info_label, "visible_ratio", 1.0, 1.0
	)
