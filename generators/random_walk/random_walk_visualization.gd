extends GeneratorVisualization

@onready var rw_tile_map: TileMapLayer = $RWTileMap

func _activate() -> void:
	for tile_coordinate: Vector2i in _floorplan.tiles:
		rw_tile_map.set_cell(tile_coordinate, 0, Vector2i(1, 1))
		await get_tree().process_frame
