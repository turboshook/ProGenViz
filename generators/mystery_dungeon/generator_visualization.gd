extends GeneratorVisualization

@onready var md_tilemap: TileMapLayer = $MDTilemap

func _activate() -> void:
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	var room_tile_atlas_coordinates: Vector2i = tile_atlas_coordinates.pick_random()
	tile_atlas_coordinates.erase(room_tile_atlas_coordinates)
	
	for room_key: int in _floorplan.rooms:
		var room_data: Dictionary = _floorplan.rooms[room_key]
		
		# draw sector
		for x: int in range(room_data.sector.position.x, room_data.sector.position.x + room_data.sector.size.x):
			for y: int in range(room_data.sector.position.y, room_data.sector.position.y + room_data.sector.size.y):
				md_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		# draw room
		for x: int in range(room_data.rect.position.x, room_data.rect.position.x + room_data.rect.size.x):
			for y: int in range(room_data.rect.position.y, room_data.rect.position.y + room_data.rect.size.y):
				md_tilemap.set_cell(Vector2i(x, y), 0, room_tile_atlas_coordinates)
		
		AudioManager.play_sound("tap")
		for _frame: int in range(4): await get_tree().physics_frame
	
	var hallway_tile_atlas_coordinates: Vector2i = tile_atlas_coordinates.pick_random()
	
	# draw hallways
	var tiles_placed: int = -1
	for hallway_key: int in _floorplan.hallways:
		var hallway_data: Dictionary = _floorplan.hallways[hallway_key]
		for tile_coordinates: Vector2i in hallway_data.tiles:
			md_tilemap.set_cell(tile_coordinates, 0, hallway_tile_atlas_coordinates)
			_tile_particles.position = (tile_coordinates * 8.0)
			if !_tile_particles.emitting: _tile_particles.set_emitting(true)
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
	_tile_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	var params: Dictionary = _floorplan.parameters
	var sector_grid_size: Vector2 = Vector2(params.x_sectors, params.y_sectors)
	var sector_size: Vector2 = Vector2(params.sector_size.x + params.sector_border, params.sector_size.y + params.sector_border)
	return ((sector_grid_size * sector_size) * 8.0)/2.0
