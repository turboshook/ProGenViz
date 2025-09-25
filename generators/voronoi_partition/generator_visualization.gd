extends GeneratorVisualization

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var tile_maps: Array[TileMapLayer] = [tile_map]

func _activate() -> void:
	var extra_tile_maps: int = int(ceil(_gen_data.cells.size()/4.0)) - 1
	if extra_tile_maps > 0:
		for i: int in range(extra_tile_maps):
			var new_tile_map: TileMapLayer = tile_map.duplicate()
			add_child(new_tile_map)
			tile_maps.append(new_tile_map)
			new_tile_map.self_modulate.a *= (float(i + 1)/float(extra_tile_maps + 1))
			# new tile maps will be visually distinct via their unique self modulation opacity
			# new opacity is equal to 1.0 * (tile_maps array index / total number of extra maps)
			# i.e., 3 tile map scenarios will have opacities of 3/3, 2/3, and 1/3
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	tile_atlas_coordinates.shuffle()
	var atlas_index: int = 0
	var tile_map_index: int = 0
	
	for x: int in range(_gen_data.map_size.x):
		for y: int in range(_gen_data.map_size.y):
			tile_map.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
	
	var tiles_placed: int = -1
	for i: int in range(_gen_data.cells.size()):
		tile_maps[tile_map_index].set_cell(_gen_data.cells[i].origin, 0, tile_atlas_coordinates[atlas_index])
		tiles_placed += 1
		if tiles_placed % 4 == 0: 
			AudioManager.play_sound("footstep")
			for _i: int in range(4): await get_tree().physics_frame
		atlas_index += 1
		if atlas_index <= tile_atlas_coordinates.size() - 1: continue
		atlas_index = 0
		tile_map_index += 1
	
	atlas_index = 0
	tile_map_index = 0
	
	for i: int in range(_gen_data.cells.size()):
		for tile: Vector2i in _gen_data.cells[i].tiles:
			tile_maps[tile_map_index].set_cell(tile, 0, tile_atlas_coordinates[atlas_index])
		AudioManager.play_sound("tap")
		for _i: int in range(4): await get_tree().physics_frame
		atlas_index += 1
		if atlas_index <= tile_atlas_coordinates.size() - 1: continue
		atlas_index = 0
		tile_map_index += 1

func get_center_offset() -> Vector2:
	return (_gen_data.map_size * 8.0) / 2.0
