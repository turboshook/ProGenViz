extends Node2D
class_name GeneratorVisualization

var _gen_data: Dictionary
var _tile_particles: CPUParticles2D

func _ready() -> void:
	if not _gen_data: return
	_tile_particles = load(
		"res://utils/generator_visualization/tile_placement_particles.tscn"
	).instantiate()
	add_child(_tile_particles)
	_activate()

func set_generation_data(gen_data: Dictionary) -> void:
	_gen_data = gen_data

func _activate() -> void:
	pass

func get_center_offset() -> Vector2:
	return Vector2.ZERO
