extends GeneratorVisualization

@onready var floor_tile_map: TileMapLayer = $FloorTileMap

func _activate() -> void:
	
	for x_coordinate: int in range(_floorplan.map_size.x):
		for y_coordinate: int in range(_floorplan.map_size.y):
			floor_tile_map.set_cell(Vector2i(x_coordinate, y_coordinate), 0, Vector2i.ZERO)
	
	var tile_atlas_coordinates: Vector2i = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)].pick_random()
	var tiles_placed: int = -1
	for tile_coordinate: Vector2i in _floorplan.tile_coordinates:
		floor_tile_map.set_cell(tile_coordinate, 0, tile_atlas_coordinates)
		tiles_placed += 1
		if tiles_placed % 8 == 0: AudioManager.play_sound("footstep")
		if tiles_placed % 2 == 0: await get_tree().physics_frame

func get_center_offset() -> Vector2:
	return Vector2(_floorplan.map_size/2) * 8.0
