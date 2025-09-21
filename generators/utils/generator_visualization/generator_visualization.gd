extends Node2D
class_name GeneratorVisualization

var _floorplan: Dictionary
var _tile_particles: CPUParticles2D

func _ready() -> void:
	if not _floorplan: return
	_tile_particles = load(
		"res://generators/utils/generator_visualization/tile_placement_particles.tscn"
	).instantiate()
	add_child(_tile_particles)
	_activate()

func set_floorplan(floorplan: Dictionary) -> void:
	_floorplan = floorplan

func _activate() -> void:
	pass

func get_center_offset() -> Vector2:
	return Vector2.ZERO
