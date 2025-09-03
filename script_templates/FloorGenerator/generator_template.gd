extends FloorGenerator

func generate(parameters: Dictionary) -> Dictionary:
	return {}

func get_parameter_interface() -> GeneratorParameterInterface:
	return null

func get_visual_representation(floorplan: Dictionary) -> Node2D:
	var node_2d: Node2D = Node2D.new()
	return node_2d
