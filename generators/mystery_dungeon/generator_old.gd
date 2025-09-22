extends FloorGenerator

const NULL_TILE: Vector2i = Vector2i(-1, -1)
const OUT_OF_BOUNDS_BUFFER: Vector2i = Vector2i(4, 2)

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
		"room_size_max": Vector2i(6, 4),
		"sector_size": Vector2i(10, 8),
		"sector_border": 3
	}

func generate(parameters: Dictionary) -> void:
	
	_floorplan = {
		"parameters": {},
		"rooms": {},
		"hallways": {},
		"meta": {
			"player_spawn": NULL_TILE,
			"floor_exit": NULL_TILE
		}
	}
	_floorplan["parameters"] = parameters
	
	# begin generating rooms within sectors
	var sector_key: int = 0
	for x_sector in range(parameters.x_sectors):
		for y_sector in range(parameters.y_sectors):
			
			# define the sector in 2D tile space
			var sector_origin: Vector2i = Vector2i(
				x_sector * (parameters.sector_size.x + parameters.sector_border) + OUT_OF_BOUNDS_BUFFER.x,
				y_sector * (parameters.sector_size.y + parameters.sector_border) + OUT_OF_BOUNDS_BUFFER.y
			) # TODO look at this once its all running again, do I want the border here all the time?
			var sector_rect: Rect2i = Rect2i(sector_origin, parameters.sector_size)
			
			# determine the size of the room
			var room_rect: Rect2i = Rect2i(0, 0, 0, 0)
			room_rect.size.x = randi_range(
				parameters.room_size_min.x, 
				parameters.room_size_max.x
			)
			room_rect.size.y = randi_range(
				parameters.room_size_min.y, 
				parameters.room_size_max.y
			)
			
			# calculate the amount of free space available to the room in its sector
			var x_wiggle_room: int = sector_rect.size.x - room_rect.size.x
			var y_wiggle_room: int = sector_rect.size.y - room_rect.size.y
			
			# determine the room's origin (top left coordinate) given available space in sector
			room_rect.position = Vector2i(
				randi_range(sector_rect.position.x, sector_rect.position.x + x_wiggle_room),
				randi_range(sector_rect.position.y, sector_rect.position.y + y_wiggle_room)
			)
			
			# create and initialize instance of DungeonRoomData to store in floorplan
			var room_data: Dictionary = ROOM_GENERATION_DATA.duplicate(true)
			
			# add entrances to rooms
			room_data.rect = room_rect
			room_data.sector = sector_rect
			if y_sector > 0:
				var north_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), -1)
				room_data.entrances.north.append(north_entrance_position)
			if y_sector < parameters.y_sectors - 1:
				var south_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), room_rect.size.y) 
				room_data.entrances.south.append(south_entrance_position)
			if x_sector < parameters.x_sectors - 1:
				var east_entrance_position: Vector2i = room_rect.position + Vector2i(room_rect.size.x, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.east.append(east_entrance_position)
			if x_sector > 0:
				var west_entrance_position: Vector2i = room_rect.position + Vector2i(-1, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.west.append(west_entrance_position)
			
			_floorplan.rooms[sector_key] = room_data
			
			# iterate ID key
			sector_key += 1
	
	# start hallway generation
	var hallway_key: int = 0
	for sector: int in _floorplan.rooms.keys():
		
		# for each sector, define start and end points for every SOUTH and EAST hallway
		var this_room_data: Dictionary = _floorplan.rooms[sector]
		if not this_room_data.entrances.south.is_empty():
			var target_room_data: Dictionary = _floorplan.rooms[sector + 1]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.south[0]
			hallway_data.end_position = target_room_data.entrances.north[0]
			_floorplan.hallways[hallway_key] = hallway_data
			hallway_key += 1

		if not this_room_data.entrances.east.is_empty():
			var target_room_data: Dictionary = _floorplan.rooms[sector + parameters.y_sectors]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.east[0]
			hallway_data.end_position = target_room_data.entrances.west[0]
			hallway_data.is_vertical = false
			_floorplan.hallways[hallway_key] = hallway_data
			hallway_key += 1
	
	# walk every hallway
	for key: int in _floorplan.hallways.keys():
		_floorplan.hallways[key].tiles = GeneratorUtils.get_middle_bend_path(
			_floorplan.hallways[key].start_position,
			_floorplan.hallways[key].end_position,
			_floorplan.hallways[key].is_vertical
		)
	
	var all_rooms: Array = _floorplan.rooms.keys()
	var spawn_room: int = all_rooms.pick_random()
	all_rooms.erase(spawn_room)
	_floorplan.meta.player_spawn = spawn_room
	_floorplan.rooms[spawn_room].meta["player_spawn"] = _get_random_tile(_floorplan.rooms[spawn_room].rect)
	
	var exit_room: int = all_rooms.pick_random()
	all_rooms.erase(exit_room)
	_floorplan.meta.floor_exit = exit_room
	_floorplan.rooms[exit_room].meta["floor_exit"] = _get_random_tile(_floorplan.rooms[exit_room].rect)

func _get_random_tile(room_rect: Rect2i) -> Vector2i:
	var random_x: int = range(room_rect.size.x).pick_random()
	var random_y: int = range(room_rect.size.y).pick_random()
	return room_rect.position + Vector2i(random_x, random_y)
