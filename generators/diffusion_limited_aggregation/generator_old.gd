extends FloorGenerator

func _init() -> void:
	_default_parameters = {
		"map_size": Vector2i(32, 32),
		"max_tiles_placed": 256,
		"max_updates": 100
	}

@warning_ignore("unused_parameter")
func generate(parameters: Dictionary) -> void:
	# Initialize center with cross shape to attempt to force more particle interactions sooner
	var center_coordinate: Vector2i = parameters.map_size/2
	var init_coord_0: Vector2i = center_coordinate + Vector2i.UP
	var init_coord_1: Vector2i = center_coordinate + Vector2i.DOWN
	var init_coord_2: Vector2i = center_coordinate + Vector2i.LEFT
	var init_coord_3: Vector2i = center_coordinate + Vector2i.RIGHT
	_floorplan = {
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
	
	var particles: Array[Dictionary] = []
	var particle_count: int = (parameters.map_size.x * parameters.map_size.y)/3
	particles.resize(particle_count)
	for i: int in range(particles.size()):
		var particle_position: Vector2i = Vector2i(
			randi_range(0, parameters.map_size.x - 1),
			randi_range(0, parameters.map_size.y - 1)
		)
		particles[i] = {
			"position": particle_position,
			"active": true
		}
	
	var particles_resolved: int = 0
	var updates: int = 0
	while (particles_resolved < (parameters.max_tiles_placed - 1)) and (particles_resolved < particles.size() - 1):
		for particle: Dictionary in particles:
			if not particle.active: continue
			particle.position += _get_in_bounds_step(particle.position, parameters.map_size)
			if not _particle_has_inactive_neighbor(particle.position): continue
			_floorplan.tile_coordinates.append(particle.position)
			_floorplan.coordinate_set[particle.position] = null
			particle.active = false
			particles_resolved += 1
		updates += 1
		if updates >= parameters.max_updates: break
	
	_floorplan.particles = particles #ehh

func _get_in_bounds_step(particle_position: Vector2i, map_size: Vector2i) -> Vector2i:
	var step_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var allowed_step_indeces: Array[int] = []
	if particle_position.y > 0: allowed_step_indeces.append(0)
	if particle_position.y < (map_size.y - 1): allowed_step_indeces.append(1)
	if particle_position.x > 0: allowed_step_indeces.append(2)
	if particle_position.x < (map_size.x - 1): allowed_step_indeces.append(3)
	return Vector2i.ZERO if allowed_step_indeces.is_empty() else step_directions[allowed_step_indeces.pick_random()]

func _particle_has_inactive_neighbor(particle_position: Vector2i) -> bool:
	return (
		_floorplan.coordinate_set.has(particle_position + Vector2i.UP) or 
		_floorplan.coordinate_set.has(particle_position + Vector2i.DOWN) or 
		_floorplan.coordinate_set.has(particle_position + Vector2i.LEFT) or 
		_floorplan.coordinate_set.has(particle_position + Vector2i.RIGHT)
	)
