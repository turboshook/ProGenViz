extends GeneratorVisualization

@onready var floor_tile_map: TileMapLayer = $FloorTileMap
@onready var walk_tile_map: TileMapLayer = $WalkTileMap

func _activate() -> void:
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	var walker_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	tile_atlas_coordinates.erase(walker_atlas_tile_coordinate)
	var floor_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	
	var tiles_placed: int = -1
	for walk_index: int in range(_floorplan.walks.size()):
		var walk: Array[Vector2i] = _floorplan.walks[walk_index]
		for walk_coordinate: Vector2i in walk:
			walk_tile_map.set_cell(walk_coordinate, 0, walker_atlas_tile_coordinate)
			tiles_placed += 1
			if tiles_placed % 32 == 0: AudioManager.play_sound("footstep")
			if tiles_placed % 8 == 0: await get_tree().physics_frame
		var tile_coordinate: Vector2i = _floorplan.tile_coordinates[walk_index]
		floor_tile_map.set_cell(tile_coordinate, 0, floor_atlas_tile_coordinate)
		walk_tile_map.clear()
