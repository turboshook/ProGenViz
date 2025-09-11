extends FloorGenerator

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	pass

func generate_from_default() -> void:
	generate(_default_parameters)

func get_parameter_table() -> GeneratorParameterTable:
	return null

func get_visualizer() -> Node2D:
	var node_2d: Node2D = Node2D.new()
	return node_2d
