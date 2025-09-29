extends MapGenerator

const NULL_ROOM: Rect2i = Rect2i(0, 0, -1, -1)

	# Template Data #
const EMPTY_gen_data: Dictionary = {
	"start_room": -1,
	"end_room": -1,
	"dead_ends": [],
	"rooms": []
}
const EMPTY_ROOM_DICTIONARY: Dictionary = {
	"room_type": "default",
	"rect": Rect2i(0, 0, 0, 0),
	"neighbors": {}
}
const ROOM_TYPE_DICTIONARY: Dictionary = {
	Vector2(1, 1): {
	}
}
const DUNGEON_ROOM_SIZES: Array[Vector2i] = [
	Vector2i(1, 1)
]

func _init() -> void:
	_default_parameters = {
		"room_count": 8,
		"max_give_ups": 3
	}
	_info_text = "\
		Info text here!\
	"

func generate(parameters: Dictionary) -> void:
	
	_gen_data = EMPTY_gen_data.duplicate(true)
	_gen_data["parameters"] = parameters
	
	var rooms_placed: int = 0 # account for starting room
	var starting_room_position: Vector2i = Vector2i(3, 3)
	var starting_room_rect: Rect2i = Rect2i(starting_room_position, Vector2i(1, 1))
	_gen_data["start_room"] = starting_room_rect
	_gen_data["rooms"].append(EMPTY_ROOM_DICTIONARY.duplicate(true))
	_gen_data.rooms[rooms_placed].rect = starting_room_rect
	var room_queue: Array[Rect2i] = [starting_room_rect]
	var current_give_ups: int = 0
	
	for current_room: Rect2i in room_queue:
		
		var exit_coordinates: Array[Vector2i] = _get_exit_coordinates(current_room)
		exit_coordinates.shuffle()
		
		for exit_coordinate: Vector2i in exit_coordinates:
			
			# Initialize this exit to point to null room so that the exit is present in the floorplan.
			_gen_data.rooms[rooms_placed].neighbors[exit_coordinate] = NULL_ROOM
			
			if rooms_placed >= _gen_data.parameters.room_count: continue
			
			var new_room_rect: Rect2i = Rect2i(exit_coordinate, Vector2i(1, 1))
			
			# How TBoI does it, rooms cannot be placed in cells where they would already have more
			# than one neighbor. I want to allow that eventually, but it involves more neighbor
			# checks that could make this loop stupid if I don't have a litte think about it.
			if _rect_is_obstructed(new_room_rect, _gen_data.rooms):
				#placed_hallway_rooms += 1
				continue
			
			# Random chance to give up creating a neighbor for this room, constrained to max_give_ups.
			if randf() >= 0.5 and current_give_ups < _gen_data.parameters.max_give_ups:
				current_give_ups += 1
				continue
			
			# Update floorplan with new additions.
			_gen_data.rooms[rooms_placed].neighbors[exit_coordinate] = new_room_rect
			rooms_placed += 1
			
			_gen_data["rooms"].append(EMPTY_ROOM_DICTIONARY.duplicate(true))
			_gen_data.rooms[rooms_placed].rect = new_room_rect
			# come back to this
			#_gen_data["rooms"][rooms_placed]["neighbors"][_get_corresponding_exit(exit_key)] = current_room_coordinate
			
			# Loop maintenance.
			room_queue.append(new_room_rect)
			
	
	# Do a pass to conclusively determine dead ends. 
	for room_key: int in range(_gen_data.rooms.size()):
		var neighbor_count: int = 0
		for exit_coordinates: Vector2i in _gen_data.rooms[room_key].neighbors:
			if _gen_data.rooms[room_key].neighbors[exit_coordinates] != NULL_ROOM:
				neighbor_count += 1
		if neighbor_count <= 1:
			_gen_data.dead_ends.append(room_key)
	
	_gen_data.end_room = _gen_data.dead_ends.pop_back()

func _get_exit_coordinates(room: Rect2i) -> Array[Vector2i]:
	var exits: Array[Vector2i] = []
	var x_end: int = room.position.x + room.size.x - 1
	var y_end: int = room.position.y + room.size.y - 1

	# Top edge (above the room).
	for x: int in range(room.position.x, x_end + 1):
		exits.append(Vector2i(x, room.position.y - 1))

	# Bottom edge (below the room).
	for x: int in range(room.position.x, x_end + 1):
		exits.append(Vector2i(x, y_end + 1))

	# Left edge (to the left of the room).
	for y: int in range(room.position.y, y_end + 1):
		exits.append(Vector2i(room.position.x - 1, y))

	# Right edge (to the right of the room).
	for y: int in range(room.position.y, y_end + 1):
		exits.append(Vector2i(x_end + 1, y))

	return exits

func _rect_is_obstructed(new_room_rect: Rect2i, rooms: Array) -> bool:
	var exits: Array[Vector2i] = _get_exit_coordinates(new_room_rect)
	for exit_coordinates: Vector2i in exits:
		var neighboring_rooms: int = 0
		for room: Dictionary in rooms:
			if room.rect.has_point(exit_coordinates): neighboring_rooms += 1
			if neighboring_rooms > 1: 
				return true
	return false
