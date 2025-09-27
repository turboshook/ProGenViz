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
		
		# check every partition for a split
		var splits: int = 0
		for partition: Dictionary in previous_partitions:
			
			# continue if partition fails the split roll
			var roll: float = randf()
			if roll > parameters.split_chance: 
				partitions.append(partition)
				continue
			
			# this section is experimental
			var possible_splits: Array[bool] = []
			if partition.rect.size.y > parameters.min_partition_size.y:
				possible_splits.append(true)
			if partition.rect.size.x > parameters.min_partition_size.x:
				possible_splits.append(false)
			if possible_splits.is_empty():
				partitions.append(partition)
				continue
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
	for partition_key: int in range(partitions.size()):
		var current_rect: Rect2i = partitions[partition_key].rect
		var center: Vector2i = current_rect.get_center()
		var check_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		
		for neighbor_key: int in range(partitions.size()):
			for direction: Vector2i in check_directions:
				var search_offset: Vector2i = (direction * 2) + ((current_rect.size/2) * direction)
				if partitions[neighbor_key].rect.has_point(center + search_offset):
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
			if neighbor_id == -1: continue
			
			# if the other partition does not recognize this one as a neighbor, no hallway will be built
			if partitions[neighbor_id].neighbors[-direction] != i:
				partitions[i].neighbors[direction] = -1
				continue
			
			# select an entrance coordinate along each wall of a room
			var wall_coordinates: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(partitions[i].room.rect, direction)
			# room entrances are always one tile outside the perimeter (optional, just plays best with my hallway code)
			var entrance_coordinate_adjusted: Vector2i = wall_coordinates.pick_random() + direction
			partitions[i].room.entrances[direction].position = entrance_coordinate_adjusted
	
	var hallways: Array[Dictionary]
	for partition_id in range(partitions.size()):
		var this_room: Dictionary = partitions[partition_id].room
		for direction: Vector2i in partitions[partition_id].neighbors.keys():
			
			if this_room.entrances[direction].position == Vector2i(-1, -1): continue
			elif this_room.entrances[direction].is_connected: continue
			
			var neighbor_partition_id: int = partitions[partition_id].neighbors[direction]
			var neighbor_room: Dictionary = partitions[neighbor_partition_id].room
			var hallway_start_position: Vector2i = this_room.entrances[direction].position
			var hallway_end_position: Vector2i = neighbor_room.entrances[-direction].position
			var hallway_dictionary: Dictionary = HALLWAY_DICTIONARY.duplicate(true)
			
			var is_vertical: bool = (direction.x == 0)
			hallway_dictionary.tile_positions = GeneratorUtils.get_middle_bend_path(
				hallway_start_position, hallway_end_position, is_vertical
			)
			this_room.entrances[direction].is_connected = true
			neighbor_room.entrances[-direction].is_connected = true
			hallways.append(hallway_dictionary)
	
	_gen_data.partitions = partitions
	_gen_data.hallways = hallways
