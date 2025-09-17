extends Node2D
class_name GeneratorVisualization

var _floorplan: Dictionary

func _ready() -> void:
	if not _floorplan: return
	_activate()

func set_floorplan(floorplan: Dictionary) -> void:
	_floorplan = floorplan

func _activate() -> void:
	pass

func get_center_offset() -> Vector2:
	return Vector2.ZERO
