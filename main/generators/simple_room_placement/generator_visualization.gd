extends GeneratorVisualization

@onready var srp_tile_map: TileMapLayer = $SRPTileMap

func _activate() -> void:
	for room: Rect2i in _gen_data.rooms:
		for x: int in range(room.position.x, room.position.x + room.size.x):
			for y: int in range(room.position.y, room.position.y + room.size.y):
				srp_tile_map.set_cell(Vector2i(x, y), 0, Vector2(1, 2))
		AudioManager.play_sound("tap")
		for _i: int in range(4): await get_tree().physics_frame
	
	for hallway: Array[Vector2i] in _gen_data.hallways:
		var tiles_placed: int = -1
		for tile_coordinates: Vector2i in hallway:
			srp_tile_map.set_cell(tile_coordinates, 0, Vector2(0, 2))
			_tile_particles.position = (tile_coordinates * 8.0)
			if !_tile_particles.emitting: _tile_particles.set_emitting(true)
			tiles_placed += 1
			if tiles_placed % 4 == 0: AudioManager.play_sound("footstep")
			await get_tree().physics_frame
	_tile_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	return (_gen_data.floor_size/2 * 8.0)
