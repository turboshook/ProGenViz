extends GeneratorParameterInterface

func get_parameters() -> Dictionary:
	return {
		"floor_tile_width": 36, 
		"floor_tile_height": 36,
		"partition_border": Vector2i(2, 2),
		"max_partition_depth": 4, 
		"min_partition_size": Vector2i(4, 4),
		"split_chance": 0.5,
		"base_partition_variance": 4,
		"min_room_size": Vector2i(3, 3)
	}
