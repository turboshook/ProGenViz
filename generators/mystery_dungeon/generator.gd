extends FloorGenerator

const NULL_TILE: Vector2i = Vector2i(-1, -1)

	# Template Data #
const ROOM_GENERATION_DATA: Dictionary = {
		"rect" = Rect2i(0, 0, 0, 0),
		"sector" = Rect2i(0, 0, 0, 0),
		"entrances" = {
			"north": [],
			"south": [],
			"east": [],
			"west": []
		},
		"meta" = {}
	}
const HALLWAY_GENERATION_DATA: Dictionary = {
		"start_position" = Vector2i.ZERO,
		"end_position" = Vector2i.ZERO,
		"is_vertical" = true,
		"tiles" = []
	}

func _init() -> void:
	_default_parameters = {
		"x_sectors": 4,
		"y_sectors": 3,
		"room_size_min": Vector2i(4, 3),
		"sector_size": Vector2i(10, 8),
		"sector_border": 3
	}
	_info_text = "\
		This style of level generation is an approximation of what is typically used across the \
		the 'mystery dungeon' rougelike subgenre, such as the 'Shiren the Wanderer' or 'Pokemon: \
		Mystery Dungeon' games.
		
		It superficially resembles a binary space partition, but the number of partitions is \
		decided ahead of time. A unique limitation of this genre is that walls are typically entire \
		tiles, so hallways have to be generated in such a way that they ensure 1-tile room entrances.
		
		These games often apply post-processing steps before generating hallways that can change the \
		feel of the layouts, such as transforming some rooms into 1x1 spaces (creating very long \
		hallways) or merging rooms from adjacent partitions into gigantic areas. \
	"

func generate(parameters: Dictionary) -> void:
	
	_gen_data = {
		"parameters": parameters,
		"rooms": {},
		"hallways": {},
		"meta": {
			"player_spawn": NULL_TILE,
			"floor_exit": NULL_TILE
		}
	}
	
	# begin generating rooms within sectors
	var sector_key: int = 0
	for x_sector: int in range(parameters.x_sectors):
		for y_sector: int in range(parameters.y_sectors):
			
			# define the sector in 2D tile space
			var sector_origin: Vector2i = Vector2i(
				x_sector * (parameters.sector_size.x + parameters.sector_border),
				y_sector * (parameters.sector_size.y + parameters.sector_border)
			)
			var sector_rect: Rect2i = Rect2i(sector_origin, parameters.sector_size)
			
			# determine the size of the room
			var room_rect: Rect2i = Rect2i(0, 0, 0, 0)
			room_rect.size.x = randi_range(parameters.room_size_min.x, parameters.sector_size.x)
			room_rect.size.y = randi_range(parameters.room_size_min.y, parameters.sector_size.y)
			
			# determine the room's origin (top left coordinate) given available space in sector
			var room_margin: Vector2i = sector_rect.size - room_rect.size
			room_rect.position = Vector2i(
				randi_range(sector_rect.position.x, sector_rect.position.x + room_margin.x),
				randi_range(sector_rect.position.y, sector_rect.position.y + room_margin.y)
			)
			
			# create and initialize instance of DungeonRoomData to store in floorplan
			var room_data: Dictionary = ROOM_GENERATION_DATA.duplicate(true)
			
			# add entrances to rooms
			room_data.rect = room_rect
			room_data.sector = sector_rect
			# TODO below could be accomplished with a loop
			if y_sector > 0:
				var north_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), -1)
				room_data.entrances.north.append(north_entrance_position)
				if room_data.rect.size.x > 5:
					var north_face_tiles: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(room_data.rect, Vector2i.UP)
					north_face_tiles.shuffle()
					for face_tile: Vector2i in north_face_tiles:
						if face_tile.distance_to(room_data.entrances.north[0]) < 2: continue
						room_data.entrances.north.append(face_tile + Vector2i.UP)
						break
			if y_sector < parameters.y_sectors - 1:
				var south_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), room_rect.size.y) 
				room_data.entrances.south.append(south_entrance_position)
				if room_data.rect.size.x > 5:
					var south_face_tiles: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(room_data.rect, Vector2i.DOWN)
					south_face_tiles.shuffle()
					for face_tile: Vector2i in south_face_tiles:
						if face_tile.distance_to(room_data.entrances.south[0]) < 2: continue
						room_data.entrances.south.append(face_tile + Vector2i.DOWN)
						break
			if x_sector < parameters.x_sectors - 1:
				var east_entrance_position: Vector2i = room_rect.position + Vector2i(room_rect.size.x, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.east.append(east_entrance_position)
				if room_data.rect.size.y > 5:
					var east_face_tiles: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(room_data.rect, Vector2i.RIGHT)
					east_face_tiles.shuffle()
					for face_tile: Vector2i in east_face_tiles:
						if face_tile.distance_to(room_data.entrances.east[0]) < 2: continue
						room_data.entrances.east.append(face_tile + Vector2i.RIGHT)
						break
			if x_sector > 0:
				var west_entrance_position: Vector2i = room_rect.position + Vector2i(-1, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.west.append(west_entrance_position)
				if room_data.rect.size.y > 5:
					var west_face_tiles: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(room_data.rect, Vector2i.LEFT)
					west_face_tiles.shuffle()
					for face_tile: Vector2i in west_face_tiles:
						if face_tile.distance_to(room_data.entrances.west[0]) < 2: continue
						room_data.entrances.west.append(face_tile + Vector2i.LEFT)
						break
			
			_gen_data.rooms[sector_key] = room_data
			
			# iterate ID key
			sector_key += 1
	
	# room post processing
	var floor_mod_roll: float = randf()
	if (parameters.x_sectors < 3 or parameters.y_sectors < 3) and floor_mod_roll < 0.5:
		var random_room_key: int = _gen_data.rooms.keys().pick_random()
		_crunch_room(_gen_data.rooms[random_room_key])
	elif (parameters.x_sectors > 3 or parameters.y_sectors > 3) and floor_mod_roll < 0.5:
		var all_keys: Array = _gen_data.rooms.keys() as Array[int]
		var room_keys: Array[int] = [all_keys.pick_random()]
		all_keys.erase(room_keys[0])
		room_keys.append(all_keys.pick_random())
		_crunch_room(_gen_data.rooms[room_keys[0]])
		_crunch_room(_gen_data.rooms[room_keys[1]])
	
	# start hallway generation
	var hallway_key: int = 0
	for sector: int in _gen_data.rooms.keys():
		
		# for each sector, define start and end points for every SOUTH and EAST hallway
		var this_room_data: Dictionary = _gen_data.rooms[sector]
		if not this_room_data.entrances.south.is_empty():
			var target_room_data: Dictionary = _gen_data.rooms[sector + 1]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.south[0]
			hallway_data.end_position = target_room_data.entrances.north[0]
			_gen_data.hallways[hallway_key] = hallway_data
			hallway_key += 1
			
			var roll: float = randf()
			if roll < 0.25 and this_room_data.entrances.south.size() > 1:
				var extra_hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
				extra_hallway_data.start_position = this_room_data.entrances.south[1]
				extra_hallway_data.end_position = target_room_data.entrances.north[0]
				_gen_data.hallways[hallway_key] = extra_hallway_data
				hallway_key += 1
			elif roll >= 0.75 and target_room_data.entrances.north.size() > 1:
				var extra_hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
				extra_hallway_data.start_position = this_room_data.entrances.south[0]
				extra_hallway_data.end_position = target_room_data.entrances.north[1]
				_gen_data.hallways[hallway_key] = extra_hallway_data
				hallway_key += 1

		if not this_room_data.entrances.east.is_empty():
			var target_room_data: Dictionary = _gen_data.rooms[sector + parameters.y_sectors]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.east[0]
			hallway_data.end_position = target_room_data.entrances.west[0]
			hallway_data.is_vertical = false
			_gen_data.hallways[hallway_key] = hallway_data
			hallway_key += 1
			
			var roll: float = randf()
			if roll < 0.25 and this_room_data.entrances.east.size() > 1:
				var extra_hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
				extra_hallway_data.start_position = this_room_data.entrances.east[1]
				extra_hallway_data.end_position = target_room_data.entrances.west[0]
				extra_hallway_data.is_vertical = false
				_gen_data.hallways[hallway_key] = extra_hallway_data
				hallway_key += 1
			elif roll >= 0.75 and target_room_data.entrances.west.size() > 1:
				var extra_hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
				extra_hallway_data.start_position = this_room_data.entrances.east[0]
				extra_hallway_data.end_position = target_room_data.entrances.west[1]
				extra_hallway_data.is_vertical = false
				_gen_data.hallways[hallway_key] = extra_hallway_data
				hallway_key += 1
	
	# walk every hallway
	for key: int in _gen_data.hallways.keys():
		_gen_data.hallways[key].tiles = GeneratorUtils.get_middle_bend_path(
			_gen_data.hallways[key].start_position,
			_gen_data.hallways[key].end_position,
			_gen_data.hallways[key].is_vertical
		)
	
	var all_rooms: Array = _gen_data.rooms.keys()
	var spawn_room: int = all_rooms.pick_random()
	all_rooms.erase(spawn_room)
	_gen_data.meta.player_spawn = spawn_room
	_gen_data.rooms[spawn_room].meta["player_spawn"] = _get_random_tile(_gen_data.rooms[spawn_room].rect)
	
	var exit_room: int = all_rooms.pick_random()
	all_rooms.erase(exit_room)
	_gen_data.meta.floor_exit = exit_room
	_gen_data.rooms[exit_room].meta["floor_exit"] = _get_random_tile(_gen_data.rooms[exit_room].rect)

func _crunch_room(room_data: Dictionary) -> void:
	var new_rect: Rect2i = Rect2i(room_data.rect.get_center(), Vector2i.ONE)
	room_data.rect = new_rect
	if not room_data.entrances.north.is_empty(): room_data.entrances.north = [new_rect.position]
	if not room_data.entrances.south.is_empty(): room_data.entrances.south = [new_rect.position]
	if not room_data.entrances.east.is_empty(): room_data.entrances.east = [new_rect.position]
	if not room_data.entrances.west.is_empty(): room_data.entrances.west = [new_rect.position]

func _get_random_tile(room_rect: Rect2i) -> Vector2i:
	var random_x: int = range(room_rect.size.x).pick_random()
	var random_y: int = range(room_rect.size.y).pick_random()
	return room_rect.position + Vector2i(random_x, random_y)
