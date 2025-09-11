extends GeneratorVisualization

@onready var isaac_tilemap: TileMapLayer = $IsaacTilemap

func _activate() -> void:
	for room_data: Dictionary in _floorplan.rooms:
		isaac_tilemap.set_cell(room_data.rect.position, 0, Vector2i(0, 0))
		await get_tree().process_frame
