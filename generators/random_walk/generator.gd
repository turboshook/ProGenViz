extends FloorGenerator

var PARAMETERS: Dictionary = {
	"walker_count": 1,
	"walker_lifetime": 128,
	"walker_turn_chance": 0.25
}

func generate(parameters: Dictionary) -> Dictionary:
	var floorplan: Dictionary = {
		"tiles": []
	}
	for _walker_id: int in range(parameters.walker_count):
		var walker_coordinate: Vector2i = Vector2i(32, 32)
		#var walker_coordinate: Vector2i = Vector2i(
			#randi_range(24, 32),
			#randi_range(24, 32)
		#)
		var step_direction: Vector2i = [
			Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT
		].pick_random() 
		for _step: int in range(parameters.walker_lifetime):
			floorplan.tiles.append(walker_coordinate)
			if randf() < parameters.walker_turn_chance:
				step_direction = _handle_turn(step_direction)
			walker_coordinate += step_direction
		
	return floorplan

func _handle_turn(step_direction: Vector2i) -> Vector2i:
	if step_direction.x == 0: return Vector2i([-1, 1].pick_random(), 0)
	return Vector2i(0, [-1, 1].pick_random())

func get_parameter_interface() -> GeneratorParameterInterface:
	return load("res://generators/random_walk/parameter_interface.tscn").instantiate()

@warning_ignore("unused_parameter")
func get_visual_representation(floorplan: Dictionary) -> Node2D:
	var tile_map: TileMapLayer = load("res://generators/random_walk/r_w_tile_map.tscn").instantiate()
	for tile_coordinate: Vector2i in floorplan.tiles:
		tile_map.set_cell(tile_coordinate, 0, Vector2i(1, 1))
	return tile_map
