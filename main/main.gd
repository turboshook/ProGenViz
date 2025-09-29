extends Node2D

const GENERATORS: Array[String] = [
	"",
	"res://main/generators/simple_room_placement/generator.gd",
	"res://main/generators/random_walk/generator.gd",
	"res://main/generators/binary_space_partition/generator.gd",
	"res://main/generators/voronoi_partition/generator.gd",
	"res://main/generators/diffusion_limited_aggregation/generator.gd",
	"res://main/generators/inverse_diffusion_limited_aggregation/generator.gd",
	"",
	"res://main/generators/isaac/generator.gd",
	"res://main/generators/mystery_dungeon/generator.gd",
	"res://main/generators/nuclear_throne/generator.gd"
]

# App UI
@onready var settings_button: Button = $CanvasLayer/UI/AppUI/SettingsButton
@onready var info_button: Button = $CanvasLayer/UI/AppUI/InfoButton
@onready var app_settings_menu: AppSettingsMenu = $CanvasLayer/UI/AppSettingsMenu
@onready var info_text_display: InfoTextDisplay = $CanvasLayer/UI/InfoTextDisplay
@onready var name_label: Label = $CanvasLayer/UI/Signature/Name
@onready var version_label: Label = $CanvasLayer/UI/Signature/Version
@onready var credit_label: Label = $CanvasLayer/UI/Signature/Credit

# Generator UI
@onready var algorithm_selection_button: OptionButton = $CanvasLayer/UI/GeneratorUI/HBoxContainer/AlgorithmSelectionButton
@onready var generate_button: Button = $CanvasLayer/UI/GeneratorUI/HBoxContainer/GenerateButton
@onready var generator_parameter_interface: GeneratorParameterInterface = $CanvasLayer/UI/GeneratorUI/ParameterInterfaceContainer/GeneratorParameterInterface

# Visualizer Interface
@onready var reset_camera_button: Button = $CanvasLayer/UI/ResetCameraButton
@onready var floor_visual_container: Node2D = $FloorVisualContainer
@onready var camera_target: Node2D = $CameraTarget
@onready var camera: Camera2D = $Camera2D

var generator_id: int = -1
var floor_generator: MapGenerator 

func _ready() -> void:
	info_text_display.set_text(
		"Welcome to ProcGenToy! Select a generation algorithm from the dropdown menu to get started."
	)
	name_label.text = str(ProjectSettings.get_setting("application/config/name"))
	version_label.text = str("[v", ProjectSettings.get_setting("application/config/version"), "]")
	credit_label.text = "by turboshook"
	
	settings_button.pressed.connect(_on_settings_button_pressed)
	info_button.pressed.connect(_on_info_button_pressed)
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
	if camera.position == camera_target.position: return
	camera.position = camera.position.lerp(camera_target.position, delta * 4.0)
	reset_camera_button.visible = (camera_target.position != Vector2(640.0, 360.0))

func _on_settings_button_pressed() -> void:
	app_settings_menu.visible = !app_settings_menu.visible
	if app_settings_menu.visible: info_text_display.visible = false

func _on_info_button_pressed() -> void:
	info_text_display.visible = !info_text_display.visible
	if info_text_display.visible: app_settings_menu.visible = false

func generate() -> void:
	if not floor_generator: return
	var parameters: Dictionary = generator_parameter_interface.get_parameters()
	if floor_visual_container.get_child_count() > 0:
		floor_visual_container.get_child(0).queue_free()
	if parameters == {}: floor_generator.generate_from_default()
	else: floor_generator.generate(parameters)
	
	# used for performance evaluation
	#var times: Array[float] = []
	#for _i: int in range(100):
		#var start_time: float = Time.get_ticks_msec()
		#floor_generator.generate(parameters)
		#times.append(Time.get_ticks_msec() - start_time)
		#await get_tree().process_frame
	#var sum: float = 0.0
	#for time: float in times: sum += time
	#print(sum / times.size())
	
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
	info_text_display.set_text(floor_generator.get_info_text())
	generate()
