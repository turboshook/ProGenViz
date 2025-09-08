extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"floor_size": Vector2i(60, 60),
		"max_room_count": 12,
		"min_room_size": Vector2i(4, 4),
		"max_room_size": Vector2i(8, 8),
		"room_padding": Vector2i(1, 1),
		"retry_threshold": 6 
	}

func generate(parameters: Dictionary) -> void:
	_floorplan = {
		"rooms": [],
		"hallways": []
	}
	var rooms: Array[Rect2i] = []
	var retries: int = 0
	var placement_complete: bool = false
	
	while !placement_complete:
		
		var new_room: Rect2i = _get_random_rect(parameters)
		var new_room_overlaps: bool = false
		
		for room: Rect2i in rooms:
			var virtual_room: Rect2i = Rect2i(
				room.position - parameters.room_padding,
				(room.position + room.size) + parameters.room_padding
			)
			if not new_room.intersects(virtual_room): continue
			retries += 1
			new_room_overlaps = true
			break
		
		if not new_room_overlaps: rooms.append(new_room)
		
		placement_complete = (
			rooms.size() >= parameters.max_room_count or
			retries >= parameters.retry_threshold
		)
	
	var hallways: Array[Array] = []
	var prev_room: Rect2i = Rect2i(0, 0, 0, 0)
	for room: Rect2i in rooms: 
		if prev_room.size != Vector2i.ZERO:
			var hallway_tiles: Array[Vector2i] = GeneratorUtils.get_simple_path(
				prev_room.get_center(),
				room.get_center(),
				bool(round(randf()))
			)
			hallways.append(hallway_tiles)
		prev_room = room
	
	_floorplan.rooms = rooms
	_floorplan.hallways = hallways

func _get_random_rect(generation_data: Dictionary) -> Rect2i:
	var room_size: Vector2i = Vector2i(
		randi_range(generation_data.min_room_size.x, generation_data.max_room_size.x),
		randi_range(generation_data.min_room_size.y, generation_data.max_room_size.y)
	)
	var room_position: Vector2i = Vector2i(
		randi_range(0, generation_data.floor_size.x - room_size.x),
		randi_range(0, generation_data.floor_size.y - room_size.y)
	)
	return Rect2i(room_position, room_size)

func get_parameter_table() -> GeneratorParameterTable:
	return load("res://generators/simple_room_placement/parameter_table.tres")

func get_visual_representation() -> Node2D:
	var tile_map: TileMapLayer = load("res://generators/simple_room_placement/s_r_p_tile_map.tscn").instantiate()
	
	for hallway: Array[Vector2i] in _floorplan.hallways:
		for tile_coordinates: Vector2i in hallway:
			tile_map.set_cell(tile_coordinates, 0, Vector2(0, 1))
	
	for room: Rect2i in _floorplan.rooms:
		for x: int in range(room.position.x, room.position.x + room.size.x):
			for y: int in range(room.position.y, room.position.y + room.size.y):
				tile_map.set_cell(Vector2i(x, y), 0, Vector2(1, 0))
	
	return tile_map
