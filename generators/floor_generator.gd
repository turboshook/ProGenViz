extends RefCounted
class_name FloorGenerator

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> Dictionary:
	return {}

func generate_from_default() -> Dictionary:
	return generate({})

func get_parameter_table() -> GeneratorParameterTable:
	return null

@warning_ignore("unused_parameter")
func get_visual_representation(floorplan: Dictionary) -> Node2D:
	var node_2d: Node2D = Node2D.new()
	return node_2d
