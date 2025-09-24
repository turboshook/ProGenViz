extends Node
class_name GeneratorUtils

static func get_bresenham_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	
	var points: Array[Vector2i] = []
	var diff_x: int = abs(end.x - start.x)
	var diff_y: int = abs(end.y - start.y)
	var x_step: int = 1 if start.x < end.x else -1
	var y_step: int = 1 if start.y < end.y else -1
	var point: Vector2i = start
	var error: int = diff_x - diff_y
	
	for i in range(max(diff_x, diff_y) + 1):
		points.append(point)
		if point == end: break
		var error_x2 : int = error * 2
		if error_x2 > -diff_y:
			error -= diff_y
			point.x += x_step
		if error_x2 < diff_x:
			error += diff_x
			point.y += y_step
	
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

static func get_rect_random_point(rect: Rect2i) -> Vector2i:
	return Vector2i(
		randi_range(rect.position.x, rect.position.x + rect.size.x - 1),
		randi_range(rect.position.y, rect.position.y + rect.size.y - 1)
	)

static func get_rect_face_coordinates(rect: Rect2i, face: Vector2i) -> Array[Vector2i]:
	
	var coordinates: Array[Vector2i] = []
	match face:
		Vector2i.UP:
			for i: int in range(rect.size.x):
				coordinates.append(Vector2i(rect.position.x + i, rect.position.y))
		Vector2i.DOWN:
			for i: int in range(rect.size.x):
				coordinates.append(Vector2i(rect.position.x + i,rect.position.y + rect.size.y - 1))
		Vector2i.LEFT:
			for i: int in range(rect.size.y):
				coordinates.append(Vector2i(rect.position.x,rect.position.y + i))
		Vector2i.RIGHT:
			for i: int in range(rect.size.y):
				coordinates.append(Vector2i(rect.position.x + rect.size.x - 1,rect.position.y + i))
		_:
			printerr("GeneratorUtils @ get_rect_face_coordinates: face must be a cardinal direction Vector2i of length 1 (Vector2.UP, etc.).")
	return coordinates
