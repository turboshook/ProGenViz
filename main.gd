extends Node2D

const GENERATORS: Array[String] = [
	"res://generators/simple_room_placement/generator.gd",
	"res://generators/mystery_dungeon/generator.gd",
	"res://generators/binary_space_partition/generator.gd",
	"res://generators/isaac/generator.gd",
	"res://generators/random_walk/generator.gd"
]

@onready var algorithm_selection_button: OptionButton = $CanvasLayer/VBoxContainer/HBoxContainer/AlgorithmSelectionButton
@onready var generate_button: Button = $CanvasLayer/VBoxContainer/HBoxContainer/GenerateButton
@onready var generator_parameter_interface: GeneratorParameterInterface = $CanvasLayer/VBoxContainer/ParameterInterfaceContainer/GeneratorParameterInterface
@onready var reset_camera_button: Button = $CanvasLayer/ResetCameraButton
@onready var floor_visual_container: Node2D = $FloorVisualContainer

var generator_id: int = -1
var floor_generator: FloorGenerator 

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
	var parameter_table: GeneratorParameterTable = floor_generator.get_parameter_table()
	generator_parameter_interface.initialize(parameter_table)
	await RenderingServer.frame_post_draw # allow param interface to populate all controls 
	generate()

func generate() -> void:
	var parameters: Dictionary = generator_parameter_interface.get_parameters()
	
	if floor_visual_container.get_child_count() > 0:
		floor_visual_container.get_child(0).queue_free()
	
	var floorplan: Dictionary = {}
	if parameters == {}: floorplan = floor_generator.generate_from_default()
	else: floorplan = floor_generator.generate(parameters)
	var visual_representation: Node2D = floor_generator.get_visual_representation(floorplan)
	floor_visual_container.add_child(visual_representation)
