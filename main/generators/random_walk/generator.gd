extends MapGenerator

func _init() -> void:
	_default_parameters = {
		"walker_count": 1,			# The amount of walkers to be simulated.
		"walker_lifetime": 128,		# The amount of steps a walker will take before the simulation ends.
		"walker_turn_chance": 0.25	# The chance for a walker to turn left or right before taking a step.
	}
	_info_text = "\
		A simple, minimally-constrained random walk. When turning, walkers will either veer left or \
		right (never 180 degrees).
		
		Low turn chances tend to create dungeon or fortress-like environments while high turn chances \
		create cave-like structures with a more natural feel.\
	"

func generate(parameters: Dictionary) -> void:
	_gen_data = {
		"walks": [], 	# Array of walked tile coordinates per walker. Order preserved for the visualizer.
		"tile_set": {} 	# Fast lookup for unique tile coordinates.
	}
	
	# For every walker
	for _walker_id: int in range(parameters.walker_count):
		var walker_coordinate: Vector2i = Vector2i(48, 48)
		var step_direction: Vector2i = [
			Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
		].pick_random() 
		var walk: Array[Vector2i] = []
		
		# For every step a walker takes
		for _step: int in range(parameters.walker_lifetime):
			# Count only coordinates that have not already been walked
			if not _gen_data.tile_set.has(walker_coordinate):
				_gen_data.tile_set[walker_coordinate] = null # some dummy value
				walk.append(walker_coordinate)
			if randf() < parameters.walker_turn_chance:
				step_direction = _handle_turn(step_direction)
			walker_coordinate += step_direction
		_gen_data.walks.append(walk)

func _handle_turn(step_direction: Vector2i) -> Vector2i:
	if step_direction.x == 0: return Vector2i([-1, 1].pick_random(), 0)
	return Vector2i(0, [-1, 1].pick_random())
