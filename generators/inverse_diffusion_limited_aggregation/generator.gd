extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"tile_quantity": 256,
		"walker_turn_chance": 0.0
	}

func generate(parameters: Dictionary) -> void:
	_floorplan = {
		"walks": [],
		"tile_coordinates": [Vector2i(32, 32)],
		"coordinate_set": {Vector2i(32, 32): null}
	}
	
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for tile_count: int in range(parameters.tile_quantity - 1):
		var walker_coordinate: Vector2i = _floorplan.tile_coordinates.pick_random()
		var step_direction = step_directions.pick_random()
		var walk: Array[Vector2i] = [walker_coordinate]
		
		var stepped_into_wall: bool = false
		while not stepped_into_wall:
			walker_coordinate += step_direction
			walk.append(walker_coordinate)
			if _floorplan.coordinate_set.has(walker_coordinate): 
				if randf() < parameters.walker_turn_chance: step_direction = step_directions.pick_random()
				continue
			stepped_into_wall = true
		
		_floorplan.walks.append(walk)
		_floorplan.tile_coordinates.append(walker_coordinate)
		_floorplan.coordinate_set[walker_coordinate] = null
