extends GeneratorVisualization

@onready var md_tilemap: TileMapLayer = $MDTilemap

func _activate() -> void:
	for room_key: int in _floorplan.rooms:
		var room_data: Dictionary = _floorplan.rooms[room_key]
		
		# draw sector
		for x: int in range(room_data.sector.position.x, room_data.sector.position.x + room_data.sector.size.x):
			for y: int in range(room_data.sector.position.y, room_data.sector.position.y + room_data.sector.size.y):
				md_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		# draw room
		for x: int in range(room_data.rect.position.x, room_data.rect.position.x + room_data.rect.size.x):
			for y: int in range(room_data.rect.position.y, room_data.rect.position.y + room_data.rect.size.y):
				md_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))
		
		AudioManager.play_sound("tap")
		for _frame: int in range(4): await get_tree().physics_frame
	
	# draw hallways
	var tiles_placed: int = -1
	for hallway_key: int in _floorplan.hallways:
		var hallway_data: Dictionary = _floorplan.hallways[hallway_key]
		for tile_coordinates: Vector2i in hallway_data.tiles:
			md_tilemap.set_cell(tile_coordinates, 0, Vector2i(0, 2))
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
