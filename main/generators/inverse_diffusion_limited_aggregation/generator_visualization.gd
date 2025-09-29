extends GeneratorVisualization

@onready var floor_tile_map: TileMapLayer = $FloorTileMap
@onready var walk_tile_map: TileMapLayer = $WalkTileMap

func _activate() -> void:
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(1,0), Vector2i(2,0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
	var walker_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	tile_atlas_coordinates.erase(walker_atlas_tile_coordinate)
	var floor_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	
	var tiles_placed: int = -1
	for walk_index: int in range(_gen_data.walks.size()):
		var walk: Array[Vector2i] = _gen_data.walks[walk_index]
		for walk_coordinate: Vector2i in walk:
			walk_tile_map.set_cell(walk_coordinate, 0, walker_atlas_tile_coordinate)
			tiles_placed += 1
			if tiles_placed % 12 == 0: AudioManager.play_sound("footstep")
			if tiles_placed % 3 == 0: await get_tree().physics_frame
		var tile_coordinate: Vector2i = _gen_data.tile_coordinates[walk_index]
		floor_tile_map.set_cell(tile_coordinate, 0, floor_atlas_tile_coordinate)
		_tile_particles.position = (tile_coordinate * 8.0)
		if !_tile_particles.emitting: _tile_particles.set_emitting(true)
		walk_tile_map.clear()
	_tile_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	return Vector2(256.0, 256.0)
