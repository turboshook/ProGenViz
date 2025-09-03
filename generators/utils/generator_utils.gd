extends Node
class_name GeneratorUtils

static func get_simple_path(start: Vector2i, end: Vector2i, vertical_first: bool = true) -> Array[Vector2i]:
	if start == end: return []
	var path_coordinates: Array[Vector2i] = [start]
	var current_coordinate: Vector2i = start
	var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1)]
	var current_step: Vector2i = steps[int(vertical_first)] * Vector2i(
		1 if sign(end.x - start.x) == 0 else sign(end.x - start.x),
		1 if sign(end.y - start.y) == 0 else sign(end.y - start.y)
	)

	var leg_complete: bool = (current_coordinate.y == end.y if current_step.x == 0 else current_coordinate.x == end.x)
	while (!leg_complete):
		current_coordinate += current_step
		path_coordinates.append(current_coordinate)
		leg_complete = (current_coordinate.y == end.y if current_step.x == 0 else current_coordinate.x == end.x)
	
	current_step = steps[int(!vertical_first)] * Vector2i(
		1 if sign(end.x - start.x) == 0 else sign(end.x - start.x),
		1 if sign(end.y - start.y) == 0 else sign(end.y - start.y)
	)
	
	leg_complete = (current_coordinate.y == end.y if current_step.x == 0 else current_coordinate.x == end.x)
	while (!leg_complete):
		current_coordinate += current_step
		path_coordinates.append(current_coordinate)
		leg_complete = (current_coordinate.y == end.y if current_step.x == 0 else current_coordinate.x == end.x)
	
	return path_coordinates
