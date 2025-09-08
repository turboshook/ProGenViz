extends RefCounted
class_name FloorGenerator

var _default_parameters: Dictionary = {}
@warning_ignore("unused_private_class_variable")
var _floorplan: Dictionary = {}

func _init() -> void:
	_default_parameters = {}

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	pass

func generate_from_default() -> void:
	generate(_default_parameters)

func get_parameter_table() -> GeneratorParameterTable:
	return null

@warning_ignore("unused_parameter")
func get_visual_representation() -> Node2D:
	var node_2d: Node2D = Node2D.new()
	return node_2d
