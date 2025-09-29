extends GeneratorVisualization

@onready var tile_map: TileMapLayer = $TileMapLayer
var _subwalker_tile_map: TileMapLayer

func _activate() -> void:
	
	_subwalker_tile_map = tile_map.duplicate()
	_subwalker_tile_map.z_index = -1
	add_child(_subwalker_tile_map)
	
	for x_coordinate: int in range(_gen_data.map_size.x):
		for y_coordinate: int in range(_gen_data.map_size.y):
			tile_map.set_cell(Vector2i(x_coordinate, y_coordinate), 0, Vector2i.ZERO)
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	tile_atlas_coordinates.shuffle()
	var tiles_placed: int = -1
	_tile_particles.set_emitting(true)
	for steps: Array in _gen_data.walker_steps:
		for i: int in range(steps.size()):
			if i == 0: tile_map.set_cell(steps[i], 0, tile_atlas_coordinates[i % 3])
			else: _subwalker_tile_map.set_cell(steps[i], 0, tile_atlas_coordinates[i % 3])
			_tile_particles.position = (steps[i] * 8.0)
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
	_tile_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	return Vector2(_gen_data.map_size/2) * 8.0
