extends FloorGenerator

var _default_parameters: Dictionary = {
	
}

func generate(parameters: Dictionary) -> Dictionary:
	return {}

func generate_from_default() -> Dictionary:
	return generate(_default_parameters)

func get_parameter_table() -> GeneratorParameterTable:
	return null

func get_visual_representation(floorplan: Dictionary) -> Node2D:
	var node_2d: Node2D = Node2D.new()
	return node_2d
