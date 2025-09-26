extends MapGenerator

	# Template Data #
const PARTITION_DICTIONARY: Dictionary = {
	"rect": Rect2i(0, 0, 0, 0),
	"neighbors": {
		Vector2i.UP: -1,
		Vector2i.DOWN: -1,
		Vector2i.RIGHT: -1,
		Vector2i.LEFT: -1
	},
	"room": {}
}

const ROOM_DICTIONARY: Dictionary = {
	"rect": Rect2i(0, 0, 0, 0),
	"entrances": { # support multiple entrances?
		Vector2i.UP: {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		Vector2i.DOWN: {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		Vector2i.RIGHT: {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		},
		Vector2i.LEFT: {
			"position": Vector2i(-1, -1),
			"is_connected": false 
		} 
	},
	"tag": ""
}

const HALLWAY_DICTIONARY: Dictionary = {
	"tile_positions": [], # Array[Vector2i]
	"tag": "" # Arbitrary data
}

func _init() -> void:
	_default_parameters = {
		"floor_tile_width": 36, 
		"floor_tile_height": 36,
		"partition_border": Vector2i(3, 3),
		"max_partition_depth": 4, 
		"min_partition_size": Vector2i(8, 8),
		"split_chance": 0.5,
		"base_partition_variance": 4,
		"min_room_size": Vector2i(3, 3)
	}
	_info_text = "
		Info text here!
	"

func generate(parameters: Dictionary) -> void:
	_gen_data = {
		"parameters": parameters,
		"partition_history": [],
		"partitions": [],
		"hallways": []
	}
	
	var partitions: Array[Dictionary] = []
	var partition_rects: Array[Rect2i] # temp, used for adjacency calculations
	
	# init partitions Dictionary with a partition representing the entire floor
	partitions.append(PARTITION_DICTIONARY.duplicate(true))
	partitions[0].rect = Rect2i(
		Vector2i.ZERO,
		Vector2i(parameters.floor_tile_width, parameters.floor_tile_height)
	)
	
	# delete old partitions and create new ones until some partition reaches the max depth
	var current_partition_depth: int = 0
	var previous_partitions: Array[Dictionary] = []
	
	while (current_partition_depth < parameters.max_partition_depth):
		previous_partitions = partitions
		partitions = []
		partition_rects = []
		
		# check every partition for a split
		var splits: int = 0
		for partition: Dictionary in previous_partitions:
			
			# continue if partition fails the split roll
			var roll: float = randf()
			if roll > parameters.split_chance: 
				partitions.append(partition)
				partition_rects.append(partition.rect)
				continue
			
			# this section is experimental
			var possible_splits: Array[bool] = []
			if partition.rect.size.y > parameters.min_partition_size.y:
				possible_splits.append(true)
			if partition.rect.size.x > parameters.min_partition_size.x:
				possible_splits.append(false)
			if possible_splits.is_empty():
				partitions.append(partition)
				partition_rects.append(partition.rect)
				continue
			
			#var horizontal_split: bool = true
			#
			#if partition.rect.size.y > partition.rect.size.x and partition.rect.size.y > parameters.min_partition_size.y:
				#
			
			var horizontal_split: bool = possible_splits.pick_random()
			
			# The split is successful, begin by duplicating the partition
			var split_0: Dictionary = partition.duplicate(true)
			var split_1: Dictionary = partition.duplicate(true)
			
			# Resize both partitions based one whether they are split along their x or y axis
			var split_position: Vector2i = partition.rect.get_center()
			var size_adjust: Vector2i = split_position - partition.rect.position
			if horizontal_split:
				split_0.rect.size.y = partition.rect.size.y - size_adjust.y
				split_1.rect.size = split_0.rect.size
				split_1.rect.position.y = split_position.y
			else:
				split_0.rect.size.x = partition.rect.size.x - size_adjust.x
				split_1.rect.size = split_0.rect.size
				split_1.rect.position.x = split_position.x
			
			# Append new partitions 
			partitions.append(split_0)
			partitions.append(split_1)
			partition_rects.append(split_0.rect)
			partition_rects.append(split_1.rect)
			horizontal_split = not horizontal_split
			splits += 1
		
		_gen_data.partition_history.append(partitions)
		# increment partition depth if a split ocurred
		if splits > 0: 
			current_partition_depth += 1
			continue
		# If no splits occurred, end with the last batch of partitions
		elif current_partition_depth < 2: continue
		break
	
	# Calculate partition neighbors
	for partition_key: int in range(partition_rects.size()):
		var current_rect: Rect2i = partition_rects[partition_key]
		var center: Vector2i = current_rect.get_center()
		var check_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
		for neighbor_key: int in range(partition_rects.size()):
			for direction: Vector2i in check_directions:
				if partition_rects[neighbor_key].has_point(center + (direction * current_rect.size)):
					partitions[partition_key].neighbors[direction] = neighbor_key
	
	# Create one room in every partition
	for i: int in range(partitions.size()):
		
		# generate room spatial data
		var room: Dictionary = ROOM_DICTIONARY.duplicate(true)
		var room_size: Vector2i = Vector2i(
			randi_range(parameters.min_room_size.x, partitions[i].rect.size.x - parameters.partition_border.x),
			randi_range(parameters.min_room_size.y, partitions[i].rect.size.y - parameters.partition_border.y)
		)
		var room_origin: Vector2i = Vector2i(
			partitions[i].rect.position.x + randi_range(0, (partitions[i].rect.size.x - room_size.x) - parameters.partition_border.x),
			partitions[i].rect.position.y + randi_range(0, (partitions[i].rect.size.y - room_size.y) - parameters.partition_border.y)
		)
		room.rect = Rect2i(room_origin, room_size)
		partitions[i].room = room
		
		# generate room entrances based on shared partition neighbor data
		for direction: Vector2i in partitions[i].neighbors.keys():
			var neighbor_id: int = partitions[i].neighbors[direction]
			if neighbor_id == -1:
				continue
			if partitions[neighbor_id].neighbors[-direction] != i:
				partitions[i].neighbors[direction] = -1
				continue
			# TODO reference the new room rect value
			#var room_rect: Rect2i = Rect2i(partitions[i].room.origin, Vector2i(partitions[i].room.width, partitions[i].room.height))
			var wall_coordinates: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(partitions[i].rect, direction)
			partitions[i].room.entrances[direction].position = wall_coordinates.pick_random()
	
	var hallways: Array[Dictionary]
	
	for partition_id in range(partitions.size()):
		var this_room: Dictionary = partitions[partition_id].room
		for direction: Vector2i in partitions[partition_id].neighbors.keys():
			
			if this_room.entrances[direction].position == Vector2i(-1, -1): continue
			elif this_room.entrances[direction].is_connected: continue
			
			# TODO
			# update to refer to partition entrances via unit vectors
			var neighbor_partition_id: int = partitions[partition_id].neighbors[direction]
			var neighbor_room: Dictionary = partitions[neighbor_partition_id].room
			var hallway_start_position: Vector2i = this_room.entrances[direction].position
			var hallway_end_position: Vector2i = neighbor_room.entrances[-direction].position
			var hallway_dictionary: Dictionary = HALLWAY_DICTIONARY.duplicate(true)
			
			# TODO 
			# replace this with GeneratorUtils hallway building functions
			# + unit vector changes as mentioned above
			hallway_dictionary.tile_positions = _get_walked_path(hallway_start_position, hallway_end_position)
			this_room.entrances[direction].is_connected = true
			neighbor_room.entrances[-direction].is_connected = true
			hallways.append(hallway_dictionary)
	
	_gen_data.partitions = partitions
	_gen_data.hallways = hallways

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
