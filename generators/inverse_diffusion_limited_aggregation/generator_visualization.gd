extends GeneratorVisualization

@onready var floor_tile_map: TileMapLayer = $FloorTileMap
@onready var walk_tile_map: TileMapLayer = $WalkTileMap
@onready var tile_placement_particles: CPUParticles2D = $TilePlacementParticles

func _activate() -> void:
	
	var tile_atlas_coordinates: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
	var walker_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	tile_atlas_coordinates.erase(walker_atlas_tile_coordinate)
	var floor_atlas_tile_coordinate: Vector2i = tile_atlas_coordinates.pick_random()
	
	var tiles_placed: int = -1
	for walk_index: int in range(_floorplan.walks.size()):
		var walk: Array[Vector2i] = _floorplan.walks[walk_index]
		for walk_coordinate: Vector2i in walk:
			walk_tile_map.set_cell(walk_coordinate, 0, walker_atlas_tile_coordinate)
			tiles_placed += 1
			if tiles_placed % 12 == 0: AudioManager.play_sound("footstep")
			if tiles_placed % 3 == 0: await get_tree().physics_frame
		var tile_coordinate: Vector2i = _floorplan.tile_coordinates[walk_index]
		floor_tile_map.set_cell(tile_coordinate, 0, floor_atlas_tile_coordinate)
		tile_placement_particles.position = (tile_coordinate * 8.0)
		if !tile_placement_particles.emitting: tile_placement_particles.set_emitting(true)
		walk_tile_map.clear()
	tile_placement_particles.set_emitting(false)

func get_center_offset() -> Vector2:
	return Vector2(256.0, 256.0)
