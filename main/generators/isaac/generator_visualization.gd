extends GeneratorVisualization

@onready var isaac_tilemap: TileMapLayer = $IsaacTilemap

func _activate() -> void:
	for room_data: Dictionary in _gen_data.rooms:
		isaac_tilemap.set_cell(room_data.rect.position, 0, Vector2i(0, 0))
		AudioManager.play_sound("tap")
		for _frame: int in range(4): await get_tree().physics_frame

func get_center_offset() -> Vector2:
	return (Vector2(_gen_data.start_room.position) * Vector2(64.0, 32.0)) + Vector2(32.0, 16.0)
