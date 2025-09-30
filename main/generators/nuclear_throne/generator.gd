extends MapGenerator

func _init() -> void:
	_default_parameters = {
		"map_size": Vector2i(32, 32),		# Total size of the map.
		"map_fill_target_proportion": 0.15,	# The proportion of map coordinates that must become tiles before the simulation can end.
		"walker_turn_chance": 0.75,			# The chance a walker will turn left or right.
		"subwalker_spawn_chance": 0.3,		# The chance for the primary walker to create a subwalker at its position on a given step.
		"subwalker_kill_chance": 0.3		# The chance a subwalker is deleted after it completes its current step.
	}
	_info_text = "\
		This method is similar to what is used to generate the maps in Nuclear Throne. The approach \
		is very similar to a random walk, but is constrained by a world map and resolves when a \
		specified proportion of the total world map area is filled with walkable tiles. Additionally, \
		it features one primary walker that has a chance to create what I am calling 'subwalkers' at \
		its current position after every step it takes. These subwalkers will each travel independently \
		and can randomly be destroyed after any of their steps. The resulting structure is often more \
		linear than a purely random walk.\
	"

func generate(parameters: Dictionary) -> void:
	_gen_data = {
		"map_size": parameters.map_size,
		"walker_steps": [], 			# Ordered list of every step taken by any walkers active during a given update.
		"tile_set": {} 					# Dictionary of tile coordinate keys for fast lookup.
	}
	
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var map_rect: Rect2i = Rect2i(Vector2i.ZERO, parameters.map_size)
	var walkers: Array[Dictionary] = [{
		"position": map_rect.get_center(),
		"step_direction": step_directions.pick_random(),
		"active": true
	}]
	_gen_data.walker_steps = [[walkers[0].position]]
	
	var total_tiles: int = parameters.map_size.x * parameters.map_size.y
	while (float(_gen_data.tile_set.size())/float(total_tiles) < parameters.map_fill_target_proportion):
		var steps: Array[Vector2i] = []
		for i: int in range(walkers.size()):
			var walker: Dictionary = walkers[i]
			
			# Walker at index 0 is always active.
			if i != 0 and !walker.active: continue
			
			# Handle turn and step updates.
			if randf() < parameters.walker_turn_chance or _next_step_out_of_bounds(walker, map_rect):
				walker.step_direction = _get_new_step_direction(walker, map_rect)
			walker.position += walkers[i].step_direction
			steps.append(walker.position)
			
			# Break from this loop using outer loop condition if the map fill target is reached mid-update.
			if (float(_gen_data.tile_set.size())/float(total_tiles) >= parameters.map_fill_target_proportion): break
			
			# Count only unique tiles toward the map fill target.
			if not _gen_data.tile_set.has(walker.position): _gen_data.tile_set[walker.position] = null
			
			# Subwalker maintenance.
			if i == 0 and randf() < parameters.subwalker_spawn_chance:
				walkers.append({
					"position": walker.position,
					"step_direction": step_directions.pick_random(),
					"active": true
				})
			elif randf() < parameters.subwalker_kill_chance:
				walker.active = false
		
		# Record every step taken this update.
		_gen_data.walker_steps.append(steps)

func _next_step_out_of_bounds(walker: Dictionary, map_rect: Rect2i) -> bool:
	var target_position: Vector2i = walker.position + walker.step_direction
	return (target_position.x < 0) or (target_position.x > map_rect.size.x - 1) or \
	(target_position.y < 0) or (target_position.y > map_rect.size.y - 1)

func _get_new_step_direction(walker: Dictionary, map_rect: Rect2i) -> Vector2i:
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var allowed_step_indeces: Array[int] = []
	if walker.position.y > 0 and walker.step_direction != Vector2i.DOWN: 
		allowed_step_indeces.append(0)
	if walker.position.y < map_rect.size.y - 1 and walker.step_direction != Vector2i.UP: 
		allowed_step_indeces.append(1)
	if walker.position.x > 0 and walker.step_direction != Vector2i.RIGHT: 
		allowed_step_indeces.append(2)
	if walker.position.x < map_rect.size.x - 1 and walker.step_direction != Vector2i.LEFT: 
		allowed_step_indeces.append(3)
	return Vector2i.ZERO if allowed_step_indeces.is_empty() else step_directions[allowed_step_indeces.pick_random()]
