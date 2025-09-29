extends MapGenerator

func _init() -> void:
	_default_parameters = {
		"tile_quantity": 128,		# The target number of tiles to be placed before the generation ends. 
		"walker_turn_chance": 0.0	# The chance a particle will turn either left or right before taking a step.
	}
	
	_info_text = "\
		This is an experiment of mine and not anything I could find described anywhere or used in \
		noteworthy projects. Maybe that isn't very surprising given how uninteresting the results \
		are. I get somewhat unique blobs every once in a while, but they're still just blobs. Maybe \
		You will come up with an interesting use case for this. :)\
	"

func generate(parameters: Dictionary) -> void:
	_gen_data = {
		"walks": [],
		"tile_coordinates": [Vector2i(32, 32)],
		"coordinate_set": {Vector2i(32, 32): null}
	}
	
	# Initialize a particle.
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for tile_count: int in range(parameters.tile_quantity - 1):
		var walker_coordinate: Vector2i = _gen_data.tile_coordinates.pick_random()
		var step_direction = step_directions.pick_random()
		var walk: Array[Vector2i] = [walker_coordinate]
		
		# Simulate that particle's motion until it steps beyond the current set of placed tiles.
		var stepped_into_wall: bool = false
		while not stepped_into_wall:
			walker_coordinate += step_direction
			walk.append(walker_coordinate)
			if _gen_data.coordinate_set.has(walker_coordinate): 
				if randf() < parameters.walker_turn_chance: step_direction = step_directions.pick_random()
				continue
			stepped_into_wall = true
		
		# Append the new tile and continue loop.
		_gen_data.walks.append(walk)
		_gen_data.tile_coordinates.append(walker_coordinate)
		_gen_data.coordinate_set[walker_coordinate] = null
