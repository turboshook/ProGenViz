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
	"room": {} # See ROOM_DICTIONARY
}

const ROOM_DICTIONARY: Dictionary = {
	"rect": Rect2i(0, 0, 0, 0),
	"entrances": {
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
	"tag": "" # Arbitrary data
}

const HALLWAY_DICTIONARY: Dictionary = {
	"tile_positions": [], # Array[Vector2i] tile coordinates in global space
	"tag": "" # Arbitrary data
}

func _init() -> void:
	_default_parameters = {
		"map_size": Vector2i(32, 32),			# Total map size.
		"max_partition_depth": 4, 				# The target number of iterations producing a partition split.
		"min_partition_size": Vector2i(8, 8),	# The minimum dimensions a partition can be. 
		"partition_border": Vector2i(3, 3),		# The amount of space subtracted from the partition's buildable space (taken from its West and South borders).
		"split_chance": 0.5,					# The chance a partition will split.
		"split_position_variance": 4,			# The range of the position offset applied to the center of a splitting partition.
		"min_room_size": Vector2i(3, 3),		# The minimum dimensions that a room can have within a partition.
		"max_room_size": Vector2i(12, 12)		# The maximum dimension that a room can have within a partition.
	}
	_info_text = "\
		This approach subdivides a 2D plane into smaller planes (partitions) until some target is met. \
		The end result resembles something similar to a simple naive room placement approach but \
		guarantees no room overlap and tends to create much more interesting floor layouts. 
		
		These rooms can be connected be a simple sequential hallway, but this implementation uses a \
		post-processing step to determine every partitions neighbors in order build explicit room \
		connections. This approach yields maps that are potentially more compliant with modern \
		games in the roguelike style and can create some interesting emergent loops.\
	"

func generate(parameters: Dictionary) -> void:
	_gen_data = {
		"parameters": parameters,
		"partition_history": [],
		"partitions": [],
		"hallways": []
	}
	
	# PARTITIONS #
	
	var partitions: Array[Dictionary] = []
	
	# Init partitions Dictionary with a partition representing the entire floor.
	partitions.append(PARTITION_DICTIONARY.duplicate(true))
	partitions[0].rect = Rect2i(Vector2i.ZERO, parameters.map_size)
	
	# Delete old partitions and create new ones until some partition reaches the max depth.
	var current_partition_depth: int = 0
	var previous_partitions: Array[Dictionary] = []
	
	while (current_partition_depth < parameters.max_partition_depth):
		previous_partitions = partitions
		partitions = []
		
		# Check every partition for a split.
		var splits: int = 0
		var updated_partitions: Dictionary = {}
		for partition: Dictionary in previous_partitions:
			
			# Continue if partition fails the split roll.
			var roll: float = randf()
			if roll > parameters.split_chance: 
				partitions.append(partition)
				continue
			
			# Define an array of bool that holds possible values for the horizontal_split variable below.
			var possible_splits: Array[bool] = []
			
			# Define boolean checks ahead of time for readability.
			var partition_is_square: bool = (partition.rect.size.y == partition.rect.size.x)
			# The >= evaluation below will favor the horizontal splits where either could occur, > will favor vertical ones.
			var partition_is_vertical_rectangle: bool = (partition.rect.size.y >= partition.rect.size.x)
			var partition_y_above_min: bool = (partition.rect.size.y >= parameters.min_partition_size.y * 2)
			var partition_x_above_min: bool = (partition.rect.size.x >= parameters.min_partition_size.x * 2)
			
			# Calculate valid partition splits based on the current partition's dimensions and then choose one at random.
			if partition_is_square:
				if partition_y_above_min: possible_splits.append(true)
				if partition_x_above_min: possible_splits.append(false)
			# Split horizontally if partition rect size y >= x.
			elif partition_is_vertical_rectangle and partition_y_above_min:
				possible_splits.append(true) 
			# Split vertically if partition rect size x < y.
			elif partition_x_above_min:
				possible_splits.append(false)
			
			# If there is no valid split, re-append and move on to the next one.
			if possible_splits.is_empty():
				partitions.append(partition) 
				continue
			var horizontal_split: bool = possible_splits.pick_random()
			
			# The split is successful, begin by duplicating the partition.
			var split_0: Dictionary = partition.duplicate(true)
			var split_1: Dictionary = partition.duplicate(true)
			
			# Resize and reposition new partitions based one whether they are split along their x or y-axis.
			var split_offset: int = randi_range(-parameters.split_position_variance, parameters.split_position_variance)
			if horizontal_split:
				# Choose a split position along the y-axis, clamped such that both resulting rects respect the min partition size.
				var split_position: int = clamp(
					(partition.rect.size.y / 2) + split_offset, 
					parameters.min_partition_size.y, 
					partition.rect.size.y - parameters.min_partition_size.y
				)
				split_0.rect.size.y = split_position
				split_1.rect.size.y = partition.rect.size.y - split_0.rect.size.y
				split_1.rect.position.y += split_0.rect.size.y
			else:
				# Choose a split position along the x-axis, clamped such that both resulting rects respect the min partition size.
				var split_position: int = clamp(
					(partition.rect.size.x / 2) + split_offset, 
					parameters.min_partition_size.x, 
					partition.rect.size.x - parameters.min_partition_size.x
				)
				split_0.rect.size.x = split_position
				split_1.rect.size.x = partition.rect.size.x - split_0.rect.size.x
				split_1.rect.position.x += split_0.rect.size.x
			
			# Append new partitions.
			partitions.append(split_0)
			partitions.append(split_1)
			updated_partitions[partition] = [split_0, split_1]
			splits += 1
		
		# Update history with all partitions from this update.
		_gen_data.partition_history.append(updated_partitions)
		
		# Increment partition depth if a split ocurred.
		if splits > 0: 
			current_partition_depth += 1
			continue
		# If no splits occurred, end with the last batch of partitions.
		elif current_partition_depth < 2: continue
		break
	
	# Find any neighbors for every partition.
	var check_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for partition_key: int in range(partitions.size()):
		var current_rect: Rect2i = partitions[partition_key].rect
		var center: Vector2i = current_rect.get_center()
		
		# For every other partition.
		for neighbor_key: int in range(partitions.size()):
			if neighbor_key == partition_key: continue # If neighbor partition is current partition.
			
			# Calculate a point just outside of the current partition in each direction and check if its touching another partition.
			for direction: Vector2i in check_directions:
				# I use direction * 2 because otherwise the calculated point may not leave the current partition due to integer divison rounding. 
				var search_offset: Vector2i = (direction * 2) + ((current_rect.size/2) * direction)
				# If the neighbor contains the point, that partition is this partition's neighbor in that face direction.
				if partitions[neighbor_key].rect.has_point(center + search_offset): 
					partitions[partition_key].neighbors[direction] = neighbor_key
	
	# ROOMS #
	
	# Create one room in every partition.
	for i: int in range(partitions.size()):
		
		# Generate room spatial data.
		var room: Dictionary = ROOM_DICTIONARY.duplicate(true)
		# Room max dimensions are straightforward under most circumstances but the min and max are 
		# both constrained by the "buildable space" (size - border) in their partition.
		var room_size: Vector2i = Vector2i(
			randi_range(
				min(parameters.min_room_size.x, partitions[i].rect.size.x - parameters.partition_border.x), 
				min(parameters.max_room_size.x, partitions[i].rect.size.x - parameters.partition_border.x)
			),
			randi_range(
				min(parameters.min_room_size.y, partitions[i].rect.size.y - parameters.partition_border.y), 
				min(parameters.max_room_size.y, partitions[i].rect.size.y - parameters.partition_border.y)
			)
		)
		# Determine the room's origin using its size and the size of its partition.
		var room_origin: Vector2i = Vector2i(
			partitions[i].rect.position.x + randi_range(0, (partitions[i].rect.size.x - room_size.x) - parameters.partition_border.x),
			partitions[i].rect.position.y + randi_range(0, (partitions[i].rect.size.y - room_size.y) - parameters.partition_border.y)
		)
		room.rect = Rect2i(room_origin, room_size)
		partitions[i].room = room
		
		# Generate room entrances based on shared partition neighbor data.
		for direction: Vector2i in partitions[i].neighbors.keys():
			var neighbor_id: int = partitions[i].neighbors[direction]
			if neighbor_id == -1: continue
			
			# If the other partition does not recognize this one as a neighbor, no hallway will be built.
			if partitions[neighbor_id].neighbors[-direction] != i:
				partitions[i].neighbors[direction] = -1
				continue
			
			# Select an entrance coordinate along each wall of a room.
			var wall_coordinates: Array[Vector2i] = GeneratorUtils.get_rect_face_coordinates(partitions[i].room.rect, direction)
			# Room entrances are always one tile outside the perimeter (optional, just plays best with my hallway code).
			var entrance_coordinate_adjusted: Vector2i = wall_coordinates.pick_random() + direction
			partitions[i].room.entrances[direction].position = entrance_coordinate_adjusted
	
	# HALLWAYS #
	
	# Connect all entrances for all rooms.
	var hallways: Array[Dictionary]
	for partition_id in range(partitions.size()):
		var this_room: Dictionary = partitions[partition_id].room
		for direction: Vector2i in partitions[partition_id].neighbors.keys():
			
			# Skip if this room has no entrance in this direction or the entrance is already connected.
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
