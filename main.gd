extends Node2D

# TODO automate this or something
const GENERATORS: Array[String] = [
	"",
	"res://generators/simple_room_placement/generator.gd",
	"res://generators/random_walk/generator.gd",
	"res://generators/binary_space_partition/generator.gd",
	"res://generators/diffusion_limited_aggregation/generator.gd",
	"res://generators/inverse_diffusion_limited_aggregation/generator.gd",
	"",
	"res://generators/isaac/generator.gd",
	"res://generators/mystery_dungeon/generator.gd"
]

@onready var algorithm_selection_button: OptionButton = $CanvasLayer/UI/VBoxContainer/HBoxContainer/AlgorithmSelectionButton
@onready var generate_button: Button = $CanvasLayer/UI/VBoxContainer/HBoxContainer/GenerateButton
@onready var generator_parameter_interface: GeneratorParameterInterface = $CanvasLayer/UI/VBoxContainer/ParameterInterfaceContainer/GeneratorParameterInterface
@onready var reset_camera_button: Button = $CanvasLayer/UI/ResetCameraButton
@onready var floor_visual_container: Node2D = $FloorVisualContainer
@onready var camera_target: Node2D = $CameraTarget
@onready var camera: Camera2D = $Camera2D

var generator_id: int = -1
var floor_generator: FloorGenerator 

func _ready() -> void:
	algorithm_selection_button.item_selected.connect(_on_item_selected)
	generate_button.pressed.connect(generate)
	reset_camera_button.pressed.connect(func(): camera_target.position = Vector2(640.0, 360.0))

func _process(delta: float) -> void:
	var scroll_vector: Vector2 = Vector2(
		Input.get_axis("input_left", "input_right"),
		Input.get_axis("input_up", "input_down")
	).normalized()
	camera_target.position += scroll_vector * 3.0
	camera_target.position.x = clamp(camera_target.position.x, 384.0, 896.0)
	camera_target.position.y = clamp(camera_target.position.y, 360.0 - 256.0, 360.0 + 256.0)
	camera.position = camera.position.lerp(camera_target.position, delta * 4.0)
	reset_camera_button.visible = (camera_target.position != Vector2(640.0, 360.0))

func generate() -> void:
	if not floor_generator: return
	var parameters: Dictionary = generator_parameter_interface.get_parameters()
	if floor_visual_container.get_child_count() > 0:
		floor_visual_container.get_child(0).queue_free()
	if parameters == {}: floor_generator.generate_from_default()
	else: floor_generator.generate(parameters)
	var visual_representation: GeneratorVisualization = floor_generator.get_visualizer()
	floor_visual_container.add_child(visual_representation)
	visual_representation.position -= visual_representation.get_center_offset()

func _on_item_selected(index: int) -> void:
	if generator_id != index and index != -1:
		generator_id = index
		floor_generator = load(GENERATORS[generator_id]).new()
	if generator_id < 0: return
	var parameter_table: GeneratorParameterTable = floor_generator.get_parameter_table()
	generator_parameter_interface.initialize(parameter_table)
	await RenderingServer.frame_post_draw # allow param interface to populate all controls 
	camera_target.position = Vector2(640.0, 360.0) # reset camera position
	generate()
