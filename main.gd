extends Node2D

const GENERATORS: Array[String] = [
	"res://generators/simple_room_placement/generator.gd",
	"res://generators/mystery_dungeon/generator.gd",
	"res://generators/binary_space_partition/generator.gd",
	"res://generators/isaac/generator.gd"
]

@onready var algorithm_selection_button: OptionButton = $CanvasLayer/VBoxContainer/AlgorithmSelectionButton
@onready var parameter_interface_container: VBoxContainer = $CanvasLayer/VBoxContainer/ParameterInterfaceContainer
@onready var generate_button: Button = $CanvasLayer/VBoxContainer/GenerateButton
@onready var reset_camera_button: Button = $CanvasLayer/ResetCameraButton
@onready var floor_visual_container: Node2D = $FloorVisualContainer

var generator_id: int = -1
var floor_generator: FloorGenerator 
var parameter_interface: GeneratorParameterInterface

func _ready() -> void:
	algorithm_selection_button.item_selected.connect(_on_item_selected)
	generate_button.pressed.connect(generate)
	reset_camera_button.pressed.connect(func(): floor_visual_container.position = Vector2.ZERO)

func _process(_delta: float) -> void:
	var scroll_vector: Vector2 = Vector2(
		Input.get_axis("input_left", "input_right"),
		Input.get_axis("input_up", "input_down")
	)
	floor_visual_container.position -= (scroll_vector * 3.0)
	reset_camera_button.visible = (floor_visual_container.position != Vector2.ZERO)

func _on_item_selected(index: int) -> void:
	if generator_id != index and index != -1:
		generator_id = index
		floor_generator = load(GENERATORS[generator_id]).new()
	if generator_id < 0: return
	parameter_interface_container.get_child(0).queue_free()
	var new_interface: GeneratorParameterInterface = floor_generator.get_parameter_interface()
	if not new_interface:
		var empty_interface: Control = load("res://utils/empty_parameter_interface.tscn").instantiate()
		parameter_interface_container.add_child(empty_interface)
		parameter_interface = null
		return
	parameter_interface = new_interface
	parameter_interface_container.add_child(new_interface)
	generate()

func generate() -> void:
	if not parameter_interface: return
	var parameters: Dictionary = parameter_interface.get_parameters()
	
	if floor_visual_container.get_child_count() > 0:
		floor_visual_container.get_child(0).queue_free()
	
	var floorplan: Dictionary = floor_generator.generate(parameters)
	var visual_representation: Node2D = floor_generator.get_visual_representation(floorplan)
	floor_visual_container.add_child(visual_representation)
