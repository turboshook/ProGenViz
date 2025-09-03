extends GeneratorParameterInterface

func get_parameters() -> Dictionary:
	return {
		"x_sectors": 4,
		"y_sectors": 3,
		"room_size_min": Vector2i(4, 3),
		"room_size_max": Vector2i(6, 4),
		"sector_size": Vector2i(10, 8),
		"sector_border": 3
	}
