extends Node
class_name GeneratorUtils

static func get_bresenham_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var x0: int = start.x
	var y0: int = start.y
	var x1: int = end.x
	var y1: int = end.y
	var diff_x: int = abs(x1 - x0)
	var diff_y: int = abs(y1 - y0)
	var sx: int = 1 if x0 < x1 else -1
	var sy: int = 1 if y0 < y1 else -1
	
	var error: int = diff_x - diff_y
	for i in range(max(diff_x, diff_y) + 1):
		points.append(Vector2i(x0, y0))
		if x0 == x1 && y0 == y1: break
		var error_2 : int = 2 * error
		if error_2 > -diff_y:
			error -= diff_y
			x0 += sx
		if error_2 < diff_x:
			error += diff_x
			y0 += sy
	return points

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

static func get_middle_bend_path(start: Vector2i, end: Vector2i, vertical_first: bool = true) -> Array[Vector2i]:
	if abs(end.y - start.y) < 2 and vertical_first: return get_simple_path(start, end, vertical_first)
	elif abs(end.x - start.x) < 2 and !vertical_first: return get_simple_path(start, end, vertical_first)
	var bend_0: Vector2i = Vector2i.ZERO
	var bend_1: Vector2i = Vector2i.ZERO
	if vertical_first:
		bend_0 = Vector2i(start.x, ((end.y + start.y) / 2))
		bend_1 = Vector2i(end.x, bend_0.y)
	else:
		bend_0 = Vector2i(((end.x + start.x) / 2), start.y)
		bend_1 = Vector2i(bend_0.x, end.y)
	
	var leg_0: Array[Vector2i] = get_simple_path(start, bend_0, vertical_first)
	leg_0.pop_back()
	var leg_1: Array[Vector2i] = get_simple_path(bend_0, bend_1, vertical_first)
	leg_1.pop_back()
	var leg_2: Array[Vector2i] = get_simple_path(bend_1, end, vertical_first)
	
	return leg_0 + leg_1 + leg_2
