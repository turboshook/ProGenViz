extends Control
class_name GeneratorParameterInterface

@onready var parameter_category_container: VBoxContainer = $ScrollContainer/MarginContainer/ParameterCategoryContainer

var _parameter_callback_store: Dictionary = {}

func initialize(param_table: GeneratorParameterTable) -> void:
	for control: Control in parameter_category_container.get_children():
		control.queue_free()
	_parameter_callback_store = {}
	
	for category: GeneratorParameterCategory in param_table.categories:
		var category_container: FoldableContainer = _create_category_container(category.name)
		parameter_category_container.add_child(category_container)
		for parameter: GeneratorParameterDefinition in category.parameters:
			if parameter is GeneratorIntParameter:
				var int_parameter: HBoxContainer = _create_int_control(parameter)
				category_container.get_child(0).add_child(int_parameter)
			elif parameter is GeneratorFloatParameter:
				var float_parameter: HBoxContainer = _create_float_control(parameter)
				category_container.get_child(0).add_child(float_parameter)
			elif parameter is GeneratorVector2iParameter:
				var vector_parameter: VBoxContainer = _create_vector2i_control(parameter)
				category_container.get_child(0).add_child(vector_parameter)

func _create_category_container(category_name: String) -> FoldableContainer:
	var category_container: FoldableContainer = FoldableContainer.new()
	var parameter_container: VBoxContainer = VBoxContainer.new()
	category_container.add_child(parameter_container)
	parameter_container.add_theme_constant_override("separation", 0)
	category_container.title = category_name
	category_container.fold()
	# TODO look into using a foldable group?
	return category_container

func _create_int_control(parameter: GeneratorIntParameter) -> HBoxContainer:
	var container: HBoxContainer = HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_END
	container.add_child(_create_parameter_name_label(parameter.name))
	var spin_box: SpinBox = SpinBox.new()
	spin_box.min_value = parameter.value_min
	spin_box.max_value = parameter.value_max
	spin_box.value = parameter.value
	container.add_child(spin_box)
	_parameter_callback_store[parameter.name] = func(): return int(spin_box.get_line_edit().text)
	return container

func _create_float_control(parameter: GeneratorFloatParameter) -> HBoxContainer:
	var container: HBoxContainer = HBoxContainer.new()
	container.alignment = BoxContainer.ALIGNMENT_END
	container.add_child(_create_parameter_name_label(parameter.name))
	var spin_box: SpinBox = SpinBox.new()
	spin_box.step = 0.01
	spin_box.min_value = parameter.value_min
	spin_box.max_value = parameter.value_max
	spin_box.value = parameter.value
	container.add_child(spin_box)
	_parameter_callback_store[parameter.name] = func(): return float(spin_box.get_line_edit().text)
	return container

func _create_vector2i_control(parameter: GeneratorVector2iParameter) -> VBoxContainer:
	var container: VBoxContainer = VBoxContainer.new()
	container.add_child(_create_parameter_name_label(parameter.name))
	
	var hbox_container: HBoxContainer = HBoxContainer.new()
	hbox_container.alignment = BoxContainer.ALIGNMENT_END
	container.add_child(hbox_container)
	
	hbox_container.add_child(_create_parameter_name_label("X:"))
	var spin_box_x: SpinBox = SpinBox.new()
	spin_box_x.min_value = parameter.value_min.x
	spin_box_x.max_value = parameter.value_max.x
	spin_box_x.value = parameter.value.x
	hbox_container.add_child(spin_box_x)
	
	hbox_container.add_child(_create_parameter_name_label("Y:"))
	var spin_box_y: SpinBox = SpinBox.new()
	spin_box_y.min_value = parameter.value_min.x
	spin_box_y.max_value = parameter.value_max.x
	spin_box_y.value = parameter.value.x
	hbox_container.add_child(spin_box_y)
	
	_parameter_callback_store[parameter.name] = func(): return Vector2i(
		int(spin_box_x.get_line_edit().text),
		int(spin_box_y.get_line_edit().text)
	)
	return container

func _create_parameter_name_label(parameter_name: String) -> Label:
	var parameter_name_label: Label = Label.new()
	parameter_name_label.text = parameter_name.capitalize()
	parameter_name_label.add_theme_font_size_override("font_size", 12)
	return parameter_name_label

func get_parameters() -> Dictionary:
	var parameters: Dictionary = {}
	for parameter_name: String in _parameter_callback_store.keys():
		parameters[parameter_name] = _parameter_callback_store[parameter_name].call()
	return parameters
