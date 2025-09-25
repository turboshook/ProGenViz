extends RefCounted
class_name FloorGenerator

var _default_parameters: Dictionary = {}
@warning_ignore("unused_private_class_variable")
var _gen_data: Dictionary = {}
@warning_ignore("unused_private_class_variable")
var _info_text: String = ""

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	pass

func generate_from_default() -> void:
	generate(_default_parameters)

func get_parameter_table() -> GeneratorParameterTable:
	var param_table_path: String = get_script().resource_path.get_base_dir() + "/parameter_table.tres"
	if !FileAccess.file_exists(param_table_path):
		printerr("FloorGenerator @ get_parameter_table(): ", param_table_path, " not found. Returning empty GeneratorParameterTable.")
		return GeneratorParameterTable.new()
	return load(param_table_path)

func get_visualizer() -> Node2D:
	var visualization_scene_path: String = get_script().resource_path.get_base_dir() + "/generator_visualization.tscn"
	if !FileAccess.file_exists(visualization_scene_path):
		printerr("FloorGenerator @ get_visualizer(): ", visualization_scene_path, " not found. Returning empty visualizer.")
		return GeneratorVisualization.new()
	var visualization: GeneratorVisualization 
	visualization = load(visualization_scene_path).instantiate()
	visualization.set_generation_data(_gen_data)
	return visualization

func get_info_text() -> String:
	return _info_text
