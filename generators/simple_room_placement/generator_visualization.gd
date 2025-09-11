extends GeneratorVisualization

@onready var srp_tile_map: TileMapLayer = $SRPTileMap

func _activate() -> void:
	for room: Rect2i in _floorplan.rooms:
		for x: int in range(room.position.x, room.position.x + room.size.x):
			for y: int in range(room.position.y, room.position.y + room.size.y):
				srp_tile_map.set_cell(Vector2i(x, y), 0, Vector2(1, 2))
				await get_tree().process_frame
	for hallway: Array[Vector2i] in _floorplan.hallways:
		for tile_coordinates: Vector2i in hallway:
			srp_tile_map.set_cell(tile_coordinates, 0, Vector2(0, 2))
			await get_tree().process_frame
