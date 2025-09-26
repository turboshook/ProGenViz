extends GeneratorVisualization

@onready var tile_map: TileMapLayer = $TileMapLayer

func _activate() -> void:
	
	for partitions: Array in _gen_data.partition_history:
		for partition: Dictionary in partitions:
			for x: int in range(partition.rect.position.x, partition.rect.position.x + partition.rect.size.x):
				for y: int in range(partition.rect.position.y, partition.rect.position.y + partition.rect.size.y):
					tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			for _frame: int in range(8): await get_tree().physics_frame
		tile_map.clear()
	 
	for partition: Dictionary in _gen_data.partitions:
		var room_data: Dictionary = partition.room
		
		# draw partition
		for x: int in range(partition.rect.position.x, partition.rect.position.x + partition.rect.size.x):
			for y: int in range(partition.rect.position.y, partition.rect.position.y + partition.rect.size.y):
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		# draw room
		for x: int in range(room_data.rect.position.x, room_data.rect.position.x + room_data.rect.size.x):
			for y: int in range(room_data.rect.position.y, room_data.rect.position.y + room_data.rect.size.y):
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(1, 2))
		
		AudioManager.play_sound("tap")
		for _frame: int in range(4): await get_tree().physics_frame
	
	# draw hallways
	var tiles_placed: int = -1
	for hallway: Dictionary in _gen_data.hallways:
		for tile_coordinates: Vector2i in hallway.tile_positions:
			tile_map.set_cell(tile_coordinates, 0, Vector2i(1, 1))
			_tile_particles.position = (tile_coordinates * 8.0)
			if !_tile_particles.emitting: _tile_particles.set_emitting(true)
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
	_tile_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	return (
		Vector2(
			_gen_data.parameters.floor_tile_width,
			_gen_data.parameters.floor_tile_height
		) * 8.0
	)/2.0
