extends GeneratorVisualization

@onready var bsp_tilemap: TileMapLayer = $BSPTilemap

func _activate() -> void:
	for partition: Dictionary in _floorplan.partitions:
		var room_data: Dictionary = partition.room
		
		# draw partition
		for x: int in range(partition.origin.x, partition.origin.x + partition.width):
			for y: int in range(partition.origin.y, partition.origin.y + partition.height):
				bsp_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		# draw room
		for x: int in range(room_data.origin.x, room_data.origin.x + room_data.width):
			for y: int in range(room_data.origin.y, room_data.origin.y + room_data.height):
				bsp_tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 2))
		
		AudioManager.play_sound("tap")
		for _frame: int in range(4): await get_tree().physics_frame
	
	# draw hallways
	var tiles_placed: int = -1
	for hallway: Dictionary in _floorplan.hallways:
		for tile_coordinates: Vector2i in hallway.tile_positions:
			bsp_tilemap.set_cell(tile_coordinates, 0, Vector2i(1, 1))
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
