extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"map_size": Vector2i(32, 32),
		"cell_count": 16
	}

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	_floorplan = {
		"map_size": parameters.map_size,
		"cells": [],
		"tiles": []
	}
	
	var map_rect: Rect2i = Rect2i(Vector2i.ZERO, parameters.map_size)
	for _i: int in range(parameters.cell_count):
		var cell_origin: Vector2i = GeneratorUtils.get_rect_random_point(map_rect)
		
		# cell origin buffer radius constraint
		# cannot resolve for small maps with relatively high cell counts
		#var cell_origin: Vector2i = Vector2i.ZERO
		#var cell_origin_isolated: bool = false
		#while !cell_origin_isolated:
			#cell_origin = GeneratorUtils.get_rect_random_point(map_rect)
			#cell_origin_isolated = true
			#for i: int in range(_floorplan.cells.size()):
				#var other_cell_origin: Vector2i = _floorplan.cells[i].origin
				#if cell_origin.distance_to(other_cell_origin) < parameters.cell_origin_buffer_radius: 
					#cell_origin_isolated = false
					#break
		
		_floorplan.cells.append({
			"origin": cell_origin,
			"tiles": []
		})
	
	_floorplan.tiles.resize(parameters.map_size.x * parameters.map_size.y)
	for x: int in range(parameters.map_size.x):
		for y: int in range(parameters.map_size.y):
			var tile_position: Vector2i = Vector2i(x, y)
			var nearest_cell_origin_key: int = -1
			var minimum_distance: float = parameters.map_size.x * parameters.map_size.y
			for i: int in range(_floorplan.cells.size()):
				var point: Vector2i = _floorplan.cells[i].origin
				if tile_position.distance_to(point) > minimum_distance: continue
				minimum_distance = tile_position.distance_to(point)
				nearest_cell_origin_key = i
			_floorplan.cells[nearest_cell_origin_key].tiles.append(tile_position)
			_floorplan.tiles.append({
				"position": tile_position,
				"cell": nearest_cell_origin_key
			})
