extends GeneratorVisualization

@onready var rw_tile_map: TileMapLayer = $RWTileMap

func _activate() -> void:
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	var atlas_index: int = randi_range(0, tile_atlas_coordinates.size() - 1)
	var tiles_placed: int = -1
	for walk: int in range(_floorplan.walks.size()):
		for tile_coordinate: Vector2i in _floorplan.walks[walk]:
			rw_tile_map.set_cell(tile_coordinate, 0, tile_atlas_coordinates[atlas_index])
			tiles_placed += 1
			if tiles_placed % 8 == 0: AudioManager.play_sound("footstep")
			await get_tree().process_frame
		atlas_index = atlas_index + 1 if atlas_index < tile_atlas_coordinates.size() - 1 else 0
