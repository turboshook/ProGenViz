extends Resource
class_name GeneratorFloorplan

var _generator_type: String = "NONE"
var _data: Dictionary = {}

func _init(generator_type: String, data: Dictionary) -> void:
	_generator_type = generator_type
	_data = data

func get_generator_type() -> String:
	return _generator_type

func get_data() -> Dictionary:
	return _data
