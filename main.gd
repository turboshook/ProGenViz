extends Node2D

const GENERATORS: Array[String] = [
	"res://generators/mystery_dungeon/generator.gd",
	"res://generators/binary_space_partition/generator.gd",
	"res://generators/isaac/generator.gd"
]

@onready var algorithm_selection_button: OptionButton = $CanvasLayer/AlgorithmSelectionButton
@onready var generate_button: Button = $CanvasLayer/GenerateButton
@onready var floor_visual_container: Node2D = $FloorVisualContainer

var generator_id: int = -1
var floor_generator: FloorGenerator 

func _ready() -> void:
	generate_button.pressed.connect(generate)

func _process(_delta: float) -> void:
	var scroll_vector: Vector2 = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	floor_visual_container.position -= scroll_vector

func generate() -> void:
	
	var selecated_id: int = algorithm_selection_button.get_selected_id()
	if generator_id != selecated_id and selecated_id != -1:
		generator_id = selecated_id
		floor_generator = load(GENERATORS[generator_id]).new()
	
	if generator_id < 0: return
	
	if floor_visual_container.get_child_count() > 0:
		floor_visual_container.get_child(0).queue_free()
	var floorplan: Dictionary = floor_generator.generate()
	var visual_representation: Node2D = floor_generator.get_visual_representation(floorplan)
	floor_visual_container.add_child(visual_representation)
