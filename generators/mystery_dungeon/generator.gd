extends FloorGenerator

const NULL_TILE: Vector2i = Vector2i(-1, -1)
const OUT_OF_BOUNDS_BUFFER: Vector2i = Vector2i(4, 2)

	# Initialization Data #
const FLOOR_GENERATION_DATA: Dictionary = {
		"x_sectors": 4,
		"y_sectors": 3,
		"room_size_min": Vector2i(4, 3),
		"room_size_max": Vector2i(6, 4),
		"sector_size": Vector2i(10, 8),
		"sector_border": 3
	}
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

const TILEMAP_PATH: String = "res://generators/mystery_dungeon/m_d_tilemap.tscn"

func generate(generation_data: Dictionary = FLOOR_GENERATION_DATA) -> Dictionary:
	
	# initialize return dictionary 
	var floorplan: Dictionary = {
		"generation_data": {},
		"rooms": {},
		"hallways": {},
		"meta": {
			"player_spawn": NULL_TILE,
			"floor_exit": NULL_TILE
		}
	}
	floorplan["generation_data"] = generation_data
	
	# begin generating rooms within sectors
	var sector_key: int = 0
	for x_sector in range(generation_data.x_sectors):
		for y_sector in range(generation_data.y_sectors):
			
			# define the sector in 2D tile space
			var sector_origin: Vector2i = Vector2i(
				x_sector * (generation_data.sector_size.x + generation_data.sector_border) + OUT_OF_BOUNDS_BUFFER.x,
				y_sector * (generation_data.sector_size.y + generation_data.sector_border) + OUT_OF_BOUNDS_BUFFER.y
			) # TODO look at this once its all running again, do I want the border here all the time?
			var sector_rect: Rect2i = Rect2i(sector_origin, generation_data.sector_size)
			
			# determine the size of the room
			var room_rect: Rect2i = Rect2i(0, 0, 0, 0)
			room_rect.size.x = randi_range(
				generation_data.room_size_min.x, 
				generation_data.room_size_max.x
			)
			room_rect.size.y = randi_range(
				generation_data.room_size_min.y, 
				generation_data.room_size_max.y
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
			
			room_data.rect = room_rect
			room_data.sector = sector_rect
			if y_sector > 0:
				var north_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), -1)
				room_data.entrances.north.append(north_entrance_position)
			if y_sector < generation_data.y_sectors - 1:
				var south_entrance_position: Vector2i = room_rect.position + Vector2i(randi_range(0, room_rect.size.x - 1), room_rect.size.y) 
				room_data.entrances.south.append(south_entrance_position)
			if x_sector < generation_data.x_sectors - 1:
				var east_entrance_position: Vector2i = room_rect.position + Vector2i(room_rect.size.x, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.east.append(east_entrance_position)
			if x_sector > 0:
				var west_entrance_position: Vector2i = room_rect.position + Vector2i(-1, randi_range(0, room_rect.size.y - 1)) 
				room_data.entrances.west.append(west_entrance_position)
			
			floorplan.rooms[sector_key] = room_data
			
			# iterate ID key
			sector_key += 1
	
	# start hallway generation
	var hallway_key: int = 0
	for sector in floorplan.rooms.keys():
		
		# for each sector, define start and end points for every SOUTH and EAST hallway
		var this_room_data: Dictionary = floorplan.rooms[sector]
		if not this_room_data.entrances.south.is_empty():
			var target_room_data: Dictionary = floorplan.rooms[sector + 1]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.south[0]
			hallway_data.end_position = target_room_data.entrances.north[0]
			floorplan.hallways[hallway_key] = hallway_data
			hallway_key += 1

		if not this_room_data.entrances.east.is_empty():
			var target_room_data: Dictionary = floorplan.rooms[sector + generation_data.y_sectors]
			var hallway_data: Dictionary = HALLWAY_GENERATION_DATA.duplicate(true)
			hallway_data.start_position = this_room_data.entrances.east[0]
			hallway_data.end_position = target_room_data.entrances.west[0]
			hallway_data.is_vertical = false
			floorplan.hallways[hallway_key] = hallway_data
			hallway_key += 1
	
	# TODO (maybe)
	# re-implement this finicky walk strategy using AStar pathfinding instead
	
	# walk every hallway
	for key in floorplan.hallways.keys():
		# initialize walker and define it travel parameters
		var start_position: Vector2i = floorplan.hallways[key].start_position
		var target_position: Vector2i = floorplan.hallways[key].end_position
		var x_steps: int = target_position.x - start_position.x
		var y_steps: int = target_position.y - start_position.y
		# uncomfortable + 1 to total steps, otherwise the walker always stops one tile short :/
		var total_steps: int = abs(x_steps) + abs(y_steps) + 1 
		# I think this is because of the turn
		
		# initialize all hallways as vertical...
		var is_vertical_at_start: bool = floorplan.hallways[key].is_vertical
		var is_vertical: int = is_vertical_at_start
		@warning_ignore("integer_division")
		var turn_step: int = (y_steps/2)
		
		# unless they are horizontal
		if not is_vertical_at_start:
			is_vertical_at_start = false
			@warning_ignore("integer_division")
			turn_step = (x_steps/2)
		
		# begin walk
		var walked_tiles: Array[Vector2i] = []
		var hallway_walker: Vector2i = start_position
		var performed_first_turn: bool = false
		for step in range(total_steps):
			
			# determine whether the first turn has been performed
			# if one is needed
			if step >= turn_step and not performed_first_turn:
				is_vertical = !(is_vertical_at_start)
				performed_first_turn = true
			
			# place a tile there
			walked_tiles.append(hallway_walker)
			
			# No elif here to handle cases where hallways are straight lines and would otherwise
			# waste a step going nowhere, stopping one tile short of connecting the two rooms.
			# In that case, immediately switch back to the former state.
			if performed_first_turn and hallway_walker.y == target_position.y: is_vertical = false
			if performed_first_turn and hallway_walker.x == target_position.x: is_vertical = true
			
			if is_vertical: hallway_walker.y += sign(y_steps)
			else: hallway_walker.x += sign(x_steps)
		
		floorplan.hallways[key].tiles = walked_tiles
	
	var all_rooms: Array = floorplan.rooms.keys()
	var spawn_room: int = all_rooms.pick_random()
	all_rooms.erase(spawn_room)
	floorplan.meta.player_spawn = spawn_room
	floorplan.rooms[spawn_room].meta["player_spawn"] = _get_random_tile(floorplan.rooms[spawn_room].rect)
	
	var exit_room: int = all_rooms.pick_random()
	all_rooms.erase(exit_room)
	floorplan.meta.floor_exit = exit_room
	floorplan.rooms[exit_room].meta["floor_exit"] = _get_random_tile(floorplan.rooms[exit_room].rect)
	
	return floorplan

func _get_random_tile(room_rect: Rect2i) -> Vector2i:
	var random_x: int = range(room_rect.size.x).pick_random()
	var random_y: int = range(room_rect.size.y).pick_random()
	return room_rect.position + Vector2i(random_x, random_y)

func get_visual_representation(floorplan: Dictionary) -> Node2D:
	var tilemap: TileMapLayer = load(TILEMAP_PATH).instantiate()
	
	for room_key: int in floorplan.rooms:
		var room_data: Dictionary = floorplan.rooms[room_key]
		
		# draw sector
		for x: int in range(room_data.sector.position.x, room_data.sector.position.x + room_data.sector.size.x):
			for y: int in range(room_data.sector.position.y, room_data.sector.position.y + room_data.sector.size.y):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
		
		# draw room
		for x: int in range(room_data.rect.position.x, room_data.rect.position.x + room_data.rect.size.x):
			for y: int in range(room_data.rect.position.y, room_data.rect.position.y + room_data.rect.size.y):
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
	
	# draw hallways
	for hallway_key: int in floorplan.hallways:
		var hallway_data: Dictionary = floorplan.hallways[hallway_key]
		for tile_coordinates: Vector2i in hallway_data.tiles:
			tilemap.set_cell(tile_coordinates, 0, Vector2i(1, 0))
	
	return tilemap
