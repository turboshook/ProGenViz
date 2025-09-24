extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"walker_count": 1,
		"walker_lifetime": 128,
		"walker_turn_chance": 0.25
	}

func generate(parameters: Dictionary) -> void:
	_floorplan = {
		"walks": [], # Ordered list of tile coordinate per walker. Used in the visualizer
		"tile_set": {} # O(1) lookup for unique tile coordinates.
	}
	
	for _walker_id: int in range(parameters.walker_count):
		var walker_coordinate: Vector2i = Vector2i(48, 48)
		var step_direction: Vector2i = [
			Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
		].pick_random() 
		var walk: Array[Vector2i] = []
		for _step: int in range(parameters.walker_lifetime):
			if not _floorplan.tile_set.has(walker_coordinate):
				_floorplan.tile_set[walker_coordinate] = null # some dummy value
				walk.append(walker_coordinate)
			if randf() < parameters.walker_turn_chance:
				step_direction = _handle_turn(step_direction)
			walker_coordinate += step_direction
		_floorplan.walks.append(walk)

func _handle_turn(step_direction: Vector2i) -> Vector2i:
	if step_direction.x == 0: return Vector2i([-1, 1].pick_random(), 0)
	return Vector2i(0, [-1, 1].pick_random())
