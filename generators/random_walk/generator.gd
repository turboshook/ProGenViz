extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"walker_count": 1,
		"walker_lifetime": 128,
		"walker_turn_chance": 0.25
	}

func generate(parameters: Dictionary) -> void:
	_floorplan = {
		"tiles": [], # ordered list of tile coordinates used in the visualizer
		"tile_set": {} # O(1) lookup for unique tile coordinates
	}
	for _walker_id: int in range(parameters.walker_count):
		var walker_coordinate: Vector2i = Vector2i(32, 32)
		var step_direction: Vector2i = [
			Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
		].pick_random() 
		for _step: int in range(parameters.walker_lifetime):
			if not _floorplan.tile_set.has(walker_coordinate):
				_floorplan.tile_set[walker_coordinate] = null # some dummy value
				_floorplan.tiles.append(walker_coordinate)
			if randf() < parameters.walker_turn_chance:
				step_direction = _handle_turn(step_direction)
			walker_coordinate += step_direction

func _handle_turn(step_direction: Vector2i) -> Vector2i:
	if step_direction.x == 0: return Vector2i([-1, 1].pick_random(), 0)
	return Vector2i(0, [-1, 1].pick_random())

func get_parameter_table() -> GeneratorParameterTable:
	return load("res://generators/random_walk/parameter_table.tres")

@warning_ignore("unused_parameter")
func get_visualizer() -> Node2D:
	var visualizer: GeneratorVisualization = load("res://generators/random_walk/random_walk_visualization.tscn").instantiate()
	visualizer.set_floorplan(_floorplan)
	return visualizer
