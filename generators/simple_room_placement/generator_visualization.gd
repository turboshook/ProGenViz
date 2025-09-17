extends GeneratorVisualization

@onready var srp_tile_map: TileMapLayer = $SRPTileMap

func _activate() -> void:
	for room: Rect2i in _floorplan.rooms:
		var tiles_placed: int = 0
		for x: int in range(room.position.x, room.position.x + room.size.x):
			for y: int in range(room.position.y, room.position.y + room.size.y):
				srp_tile_map.set_cell(Vector2i(x, y), 0, Vector2(1, 2))
				tiles_placed += 1
				if tiles_placed % 2 == 0: AudioManager.play_sound("tap")
				await get_tree().physics_frame
	
	for hallway: Array[Vector2i] in _floorplan.hallways:
		var tiles_placed: int = -1
		for tile_coordinates: Vector2i in hallway:
			srp_tile_map.set_cell(tile_coordinates, 0, Vector2(0, 2))
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame

func get_center_offset() -> Vector2:
	return (_floorplan.floor_size/2 * 8.0)
