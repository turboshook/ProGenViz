extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"map_size": Vector2i(32, 32),
		"max_tiles_placed": 128,
		"particle_spawn_density": 3,
		"max_updates": 150
	}
	_info_text = "
		Info text here!
	"

func generate(parameters: Dictionary) -> void:
	# Initialize center with cross shape to attempt to force more particle interactions sooner
	var center_coordinate: Vector2i = parameters.map_size/2
	var init_coord_0: Vector2i = center_coordinate + Vector2i.UP
	var init_coord_1: Vector2i = center_coordinate + Vector2i.DOWN
	var init_coord_2: Vector2i = center_coordinate + Vector2i.LEFT
	var init_coord_3: Vector2i = center_coordinate + Vector2i.RIGHT
	_gen_data = {
		"map_size": parameters.map_size,
		"tile_coordinates": [
			center_coordinate,
			init_coord_0,
			init_coord_1,
			init_coord_2,
			init_coord_3
		],
		"coordinate_set": {
			center_coordinate: null,
			init_coord_0: null,
			init_coord_1: null,
			init_coord_2: null,
			init_coord_3: null
		},
		"updates": 0,
		"particles": []
	}
	
	var particle_active_rect: Rect2i = Rect2i(Vector2i.ZERO, parameters.map_size/4)
	particle_active_rect.position = (parameters.map_size)/2 - (particle_active_rect.size)/2
	var particles: Array[Dictionary] = []
	particles.resize((particle_active_rect.size.x * particle_active_rect.size.y)/parameters.particle_spawn_density)
	for i: int in range(particles.size()):
		particles[i] = {
			"position": _pick_random_point(particle_active_rect),
			"active": true
		}
	
	# simulate until we have placed the maximum allowable number of tiles 
	while (_gen_data.tile_coordinates.size() < parameters.max_tiles_placed):
		for particle: Dictionary in particles:
			if not particle.active: continue # skip inactive particles
			
			# constrain particle movement
			particle.position += _get_in_bounds_step(particle.position, particle_active_rect)
			
			if not _particle_has_inactive_neighbor(particle.position): continue
			# partlce has joined the aggregation, place a tile
			_gen_data.tile_coordinates.append(particle.position)
			_gen_data.coordinate_set[particle.position] = null
			particle.active = false
			
			# if placed the maximum allowable tiles, stop processing particles (will also end while loop)
			if _gen_data.tile_coordinates.size() >= parameters.max_tiles_placed: break
			
			# if all current particles have been resolved or the last tile placed is at the edge of the active rect
			if _gen_data.tile_coordinates.size() != particles.size() and \
			not _point_on_rect_perimeter(particle.position, particle_active_rect): continue
			# expand active particle region if last particle hit the boundary
			if particle_active_rect.size == parameters.map_size: continue
			var prev_rect: Rect2i = particle_active_rect
			particle_active_rect = particle_active_rect.grow(4)
			
			# spawn new particles in the newly-expanded active rect, excluding points intersected by the old rect
			var new_particles: Array[Dictionary] = []
			new_particles.resize((particle_active_rect.size.x * particle_active_rect.size.y)/(parameters.particle_spawn_density * 2))
			for i: int in range(new_particles.size()):
				new_particles[i] = {
					"position": _get_point_excluding(particle_active_rect, prev_rect),
					"active": true
				}
			particles = particles + new_particles
		
		# alternatively, end simulation if we have reached the maximum update count
		_gen_data.updates += 1
		if _gen_data.updates >= parameters.max_updates: break
	
	_gen_data.particles = particles # used to visualize unresolved particles

func _get_in_bounds_step(particle_position: Vector2i, active_region: Rect2i) -> Vector2i:
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var allowed_step_indeces: Array[int] = []
	if particle_position.y > active_region.position.y: allowed_step_indeces.append(0)
	if particle_position.y < (active_region.position.y + active_region.size.y - 1): allowed_step_indeces.append(1)
	if particle_position.x > active_region.position.x: allowed_step_indeces.append(2)
	if particle_position.x < (active_region.position.x + active_region.size.x - 1): allowed_step_indeces.append(3)
	return Vector2i.ZERO if allowed_step_indeces.is_empty() else step_directions[allowed_step_indeces.pick_random()]

func _particle_has_inactive_neighbor(particle_position: Vector2i) -> bool:
	return (
		_gen_data.coordinate_set.has(particle_position + Vector2i.UP) or 
		_gen_data.coordinate_set.has(particle_position + Vector2i.DOWN) or 
		_gen_data.coordinate_set.has(particle_position + Vector2i.LEFT) or 
		_gen_data.coordinate_set.has(particle_position + Vector2i.RIGHT)
	)

func _pick_random_point(rect: Rect2i) -> Vector2i:
	return Vector2i(
		randi_range(rect.position.x, rect.position.x + rect.size.x),
		randi_range(rect.position.y, rect.position.y + rect.size.y)
	)

func _point_on_rect_perimeter(particle_position: Vector2i, active_region: Rect2i) -> bool:
	return (
		particle_position.x == (active_region.position.x + active_region.size.x) or
		particle_position.x == active_region.position.x or
		particle_position.y == (active_region.position.y + active_region.size.y) or
		particle_position.y == active_region.position.y
	)

func _get_point_excluding(from: Rect2i, excluding: Rect2i) -> Vector2i:
	var intersection: Rect2i = from.intersection(excluding)
	if intersection == Rect2i(): # no intersection, unconstrained selection
		return Vector2i(
			randi_range(from.position.x, from.position.x + from.size.x - 1),
			randi_range(from.position.y, from.position.y + from.size.y - 1)
		)
	
	# randomly choose between horizontal-first or vertical-first partitioning
	if randf() > 0.5:
		var left_width: int = intersection.position.x - from.position.x
		var right_width: int = (from.position.x + from.size.x) - (intersection.position.x + intersection.size.x)
		if left_width > 0 and (right_width == 0 or randf() < float(left_width) / float(left_width + right_width)):
			# pick from left band
			return Vector2i(
				randi_range(from.position.x, intersection.position.x - 1), 
				randi_range(from.position.y, from.position.y + from.size.y - 1)
			)
		# pick from right band
		return Vector2i(
			randi_range(intersection.position.x + intersection.size.x, from.position.x + from.size.x - 1),
			randi_range(from.position.y, from.position.y + from.size.y - 1)
		)
	
	var top_height: int = intersection.position.y - from.position.y
	var bottom_height: int = (from.position.y + from.size.y) - (intersection.position.y + intersection.size.y)
	if top_height > 0 and (bottom_height == 0 or randf() < float(top_height) / float(top_height + bottom_height)):
		# pick from top band
		return Vector2i(
			randi_range(from.position.x, from.position.x + from.size.x - 1),
			randi_range(from.position.y, intersection.position.y - 1)
		)
	# pick from bottom band
	return Vector2i(
		randi_range(from.position.x, from.position.x + from.size.x - 1),
		randi_range(intersection.position.y + intersection.size.y, from.position.y + from.size.y - 1)
	)
