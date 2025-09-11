extends FloorGenerator

const TILEMAP_PATH: String = "res://generators/binary_space_partition/b_s_p_tilemap.tscn"

	# Template Data #
const PARTITION_DICTIONARY: Dictionary = {
	"origin": Vector2i(-1, -1),
	"height": 0,
	"width": 0,
	"neighbors": {
		"north": -1,
		"south": -1,
		"east": -1,
		"west": -1
	},
	"room": {}
}
const ROOM_DICTIONARY: Dictionary = {
	"origin": Vector2i(-1, -1),
	"height": 0,
	"width": 0,
	"entrances": { # support multiple entrances?
		"north": {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		"south": {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		"east": {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		"west": {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		} 
	},
	"tag": "",
	"prefab": ""
}

const HALLWAY_DICTIONARY: Dictionary = {
	"tile_positions": [], # Array[Vector2i]
	"tag": "" #idk
}

var _partitions: Array[Dictionary] = []
var _hallways: Array[Dictionary] = []

func _init() -> void:
	_default_parameters = {
		"floor_tile_width": 36, 
		"floor_tile_height": 36,
		"partition_border": Vector2i(2, 2),
		"max_partition_depth": 4, 
		"min_partition_size": Vector2i(4, 4),
		"split_chance": 0.5,
		"base_partition_variance": 4,
		"min_room_size": Vector2i(3, 3)
	}

func generate(parameters: Dictionary) -> void:
	_partitions = _generate_partitions(parameters)
	_generate_rooms(parameters)
	_hallways = _generate_hallways()
	_floorplan = {
		"partitions": _partitions,
		"hallways": _hallways
	}

func _generate_partitions(parameters: Dictionary) -> Array[Dictionary]:
	
	var partitions: Array[Dictionary]
	var partition_rects: Array[Rect2i] # temp, used for adjacency calculations
	
	# init partitions Dictionary with a partition representing the entire floor
	partitions.append(PARTITION_DICTIONARY.duplicate(true))
	partitions[0]["origin"] = Vector2i.ZERO
	partitions[0]["width"] = parameters.floor_tile_width
	partitions[0]["height"] = parameters.floor_tile_height
	
	var current_partition_depth: int = 0
	var previous_partitions: Array[Dictionary]
	var horizontal_split: bool = bool(randi_range(0, 1))
	while (current_partition_depth < parameters.max_partition_depth):
		previous_partitions = partitions
		partitions = []
		partition_rects = []
		
		var splits: int = 0
		for partition in previous_partitions:
			var roll: float = randf()
			if roll < 0.5 and current_partition_depth > 3:
				partitions.append(partition)
				partition_rects.append(Rect2i(partition["origin"], Vector2i(partition["width"], partition["height"])))
				horizontal_split = not horizontal_split
				continue
			
			var partition_0: Dictionary = partition.duplicate(true)
			var partition_1: Dictionary = partition_0.duplicate(true)
			
			var can_split: bool = false
			
			if horizontal_split and partition_0["height"] / 2 > parameters.min_partition_size.y:
				can_split = true
				var slice_position: int = partition_0["height"] / 2 
				var base_height_min: int = max(parameters.min_partition_size.y, slice_position - parameters.base_partition_variance)
				var base_height_max: int = min(partition_0["height"] - parameters.min_partition_size.y, slice_position + parameters.base_partition_variance)
				partition_0["height"] = randi_range(base_height_min, base_height_max)
				partition_1["origin"] = Vector2i(partition_0["origin"].x, partition_0["origin"].y + partition_0["height"])
				partition_1["height"] = partition_1["height"] - partition_0["height"]
			elif not horizontal_split and partition_0["width"] / 2 > parameters.min_partition_size.x:
				can_split = true
				var slice_position: int = partition_0["width"] / 2 
				var base_width_min: int = max(parameters.min_partition_size.x, slice_position - parameters.base_partition_variance)
				var base_width_max: int = min(partition_0["width"] - parameters.min_partition_size.x, slice_position + parameters.base_partition_variance)
				partition_0["width"] = randi_range(base_width_min, base_width_max)
				partition_1["origin"] = Vector2i(partition_0["origin"].x + partition_0["width"], partition_0["origin"].y)
				partition_1["width"] = partition_1["width"] - partition_0["width"]
			
			if can_split:
				partitions.append(partition_0)
				partitions.append(partition_1)
				partition_rects.append(Rect2i(partition_0["origin"], Vector2i(partition_0["width"], partition_0["height"])))
				partition_rects.append(Rect2i(partition_1["origin"], Vector2i(partition_1["width"], partition_1["height"])))
				splits += 1
			else:
				partitions.append(partition)
				partition_rects.append(Rect2i(partition["origin"], Vector2i(partition["width"], partition["height"])))
		
		if splits > 0:
			current_partition_depth += 1
			horizontal_split = not horizontal_split
			continue
		elif current_partition_depth < 2:
			partitions = previous_partitions # try again if depth < 2
			continue
		break
	
	for i in range(partition_rects.size()):
		var current_rect: Rect2i = partition_rects[i]
		var center: Vector2i = current_rect.get_center()
		
		# Find and assign neighbors in the four cardinal directions
		for n in range(partition_rects.size()):
			@warning_ignore("integer_division")
			if partition_rects[n].has_point(center - Vector2i(0, current_rect.size.y/2 + 2)):
				partitions[i]["neighbors"]["north"] = n
				break
		for s in range(partition_rects.size()):
			@warning_ignore("integer_division")
			if partition_rects[s].has_point(center + Vector2i(0, current_rect.size.y/2 + 2)):
				partitions[i]["neighbors"]["south"] = s
				break
		for e in range(partition_rects.size()):
			@warning_ignore("integer_division")
			if partition_rects[e].has_point(center + Vector2i(current_rect.size.x/2 + 2, 0)):
				partitions[i]["neighbors"]["east"] = e
				break
		for w in range(partition_rects.size()):
			@warning_ignore("integer_division")
			if partition_rects[w].has_point(center - Vector2i(current_rect.size.x/2 + 2, 0)):
				partitions[i]["neighbors"]["west"] = w
				break
	
	return partitions

func _generate_rooms(parameters: Dictionary) -> void:
	for i in range(_partitions.size()):
		
		# generate room spatial data
		var room: Dictionary = ROOM_DICTIONARY.duplicate(true)
		room["width"] = randi_range(parameters.min_room_size.x, _partitions[i]["width"] - parameters.partition_border.x)
		room["height"] = randi_range(parameters.min_room_size.y, _partitions[i]["height"] - parameters.partition_border.y)
		room["origin"] = Vector2i(
			_partitions[i]["origin"].x + randi_range(0, (_partitions[i]["width"] - room["width"]) - parameters.partition_border.x),
			_partitions[i]["origin"].y + randi_range(0, (_partitions[i]["height"] - room["height"]) - parameters.partition_border.y)
		)
		_partitions[i]["room"] = room
		# rooms can have coordinates that are outside their partition if the partitions become too small, this is a bug
		# which way should the constraint go?
		
		# generate room entrances based on shared partition neighbor data
		for direction_string in _partitions[i]["neighbors"].keys():
			var neighbor_id: int = _partitions[i]["neighbors"][direction_string]
			if neighbor_id == -1:
				continue
			var opposite_direction_string: String = _get_opposite_direction(direction_string)
			if _partitions[neighbor_id]["neighbors"][opposite_direction_string] != i:
				_partitions[i]["neighbors"][direction_string] = -1
				continue
			_partitions[i]["room"]["entrances"][direction_string]["position"] = _get_random_wall_coordinate(_partitions[i]["room"], direction_string)

func _generate_hallways() -> Array[Dictionary]:
	
	var hallways: Array[Dictionary]
	
	for partition_id in range(_partitions.size()):
		var this_room: Dictionary = _partitions[partition_id]["room"]
		for direction_string: String in _partitions[partition_id]["neighbors"].keys():
			
			if this_room["entrances"][direction_string]["position"] == Vector2i(-1, -1):
				continue
			elif this_room["entrances"][direction_string]["is_connected"]:
				continue
			
			var neighbor_partition_id: int = _partitions[partition_id]["neighbors"][direction_string]
			var neighbor_room: Dictionary = _partitions[neighbor_partition_id]["room"]
			var hallway_start_position: Vector2i = this_room["entrances"][direction_string]["position"]
			var opposite_direction_string: String = _get_opposite_direction(direction_string)
			var hallway_end_position: Vector2i = neighbor_room["entrances"][opposite_direction_string]["position"]
			var hallway_dictionary: Dictionary = HALLWAY_DICTIONARY.duplicate(true)
			
			hallway_dictionary["tile_positions"] = _get_walked_path(hallway_start_position, hallway_end_position)
			this_room["entrances"][direction_string]["is_connected"] = true
			neighbor_room["entrances"][opposite_direction_string]["is_connected"] = true
			hallways.append(hallway_dictionary)
	
	return hallways

# this needs to be replaced with an astar path that takes room into account, no 
# hallways overlapping with rooms (hallways overlapping with eachother is fine)
func _get_walked_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current_pos: Vector2i = start
	
	path.append(current_pos)
	
	var halfway: int = (abs(end.x - start.x) + abs(end.y - start.y)) / 2
	var steps: int = 0
	
	while current_pos != end:
		if steps < halfway:
			if current_pos.x != end.x:
				current_pos.x += 1 if end.x > current_pos.x else -1
			elif current_pos.y != end.y:
				current_pos.y += 1 if end.y > current_pos.y else -1
		else:
			if current_pos.y != end.y:
				current_pos.y += 1 if end.y > current_pos.y else -1
			elif current_pos.x != end.x:
				current_pos.x += 1 if end.x > current_pos.x else -1
		
		path.append(current_pos)
		steps += 1
	
	return path

func _get_random_wall_coordinate(room_dictionary: Dictionary, wall_face: String) -> Vector2i:
	if wall_face.to_lower() == "north":
		return Vector2i(
				room_dictionary["origin"].x + randi_range(0, room_dictionary["width"] - 1),
				room_dictionary["origin"].y - 1
			)
	elif wall_face.to_lower() == "south":
		return Vector2i(
				room_dictionary["origin"].x + randi_range(0, room_dictionary["width"] - 1),
				room_dictionary["origin"].y + room_dictionary["height"]
			)
	elif wall_face.to_lower() == "east":
		return Vector2i(
				room_dictionary["origin"].x + room_dictionary["width"],
				room_dictionary["origin"].y + randi_range(0, room_dictionary["height"] - 1)
			)
	elif wall_face.to_lower() == "west":
		return Vector2i(
				room_dictionary["origin"].x - 1,
				room_dictionary["origin"].y + randi_range(0, room_dictionary["height"] - 1)
			)
	return Vector2i(-1, -1)

func _get_opposite_direction(direction_string: String) -> String:
	if direction_string.to_lower() == "north": return "south"
	if direction_string.to_lower() == "south": return "north"
	if direction_string.to_lower() == "east": return "west"
	if direction_string.to_lower() == "west": return "east"
	return "bad direction"
