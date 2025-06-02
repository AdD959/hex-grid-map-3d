extends Node3D

var current_tile_position_x = 0
var current_tile_position_z = 0
var row_position = 0
var row_step = 0
const TILE_COMPOSITE = preload("res://tile_composite.tscn")
const UNIT_CYCLINDER = preload("res://unit_cyclinder.glb")
const TREE_1 = preload("res://tile_stuff/trees/tree-1.tscn")
const TILE_INNER_GRASS_SCENE = preload("res://tile_stuff/tile_grass/tile_inner_grass_scene.tscn")
var composite_tile_count = 0
const TILE_TYPES := ["forest", "grass"]
const HEXAGON_GRASS_DARK = preload("res://tile_stuff/tile_grass/hexagon-grass-dark/hexagon-grass-dark.tscn")

func _ready() -> void:
	_instantiate_multimesh_assets()
	_generate_map()
	#_generate_map_2()
	#_add_unit()
	
func _instantiate_multimesh_assets():
	Globals.grass_tile = TILE_INNER_GRASS_SCENE.instantiate()
	Globals.dark_grass_tile = HEXAGON_GRASS_DARK.instantiate()
	Globals.tree_1_multimesh = TREE_1.instantiate()
	add_child(Globals.grass_tile)
	add_child(Globals.dark_grass_tile)
	add_child(Globals.tree_1_multimesh)
	
func _add_unit():
	var unit = UNIT_CYCLINDER.instantiate()
	unit.name = "unit"
	
	var outer_tile = Globals.tile_data_map[Vector2i(0, 0)]
	var inner_tile = outer_tile.inner_tiles_data_map[Vector2i(0, 0)]
	
	# Combine outer tile's world position with inner tile's local offset
	unit.position = outer_tile.position 
	#+ inner_tile.position

	self.add_child(unit)
	Globals.selected_unit = unit
	
func _generate_map():
	var tile_width = 28   # Distance between centers horizontally (flat-top hex)
	var tile_height = 24.7     # Distance between centers vertically (row spacing)
	
	var total_tiles = Globals.GRID_WIDTH * Globals.GRID_HEIGHT * 37
	Globals.grass_tile.multimesh.instance_count = total_tiles
	Globals.dark_grass_tile.multimesh.instance_count = total_tiles
	Globals.tree_1_multimesh.multimesh.instance_count = total_tiles
	
	var x_shift = 0
	var z_shift = 0
	var z_shift_odd = 10
	var z_shift_even = 0
	for x in range(Globals.GRID_WIDTH):
		var is_even_row = true if x % 2 == 0 else false
		for z in range(Globals.GRID_HEIGHT):
			var tile_new = TILE_COMPOSITE.duplicate(true).instantiate()
			var z_axis_z_offset = 23.5
			var z_axis_x_offset = -2 
			var x_axis_z_offset = 3.5 # BUT even rows also have an additional 13.5 (or maybe just starts at 13.5 then accumulated 3.5) 
			var x_axis_x_offset = 22 # BUT even rows are 20
			
			var x_pos = (-2.0 * z) + x_shift
			var z_pos = 23.5 * z
			
			tile_new.position = Vector3(
				x_pos,
				0,       # Y is not used in positioning
				z_pos + z_shift_even if x % 2 == 0 else z_pos + z_shift_odd
			)
			
			var tile_pos = Vector2i(x, z)
			tile_new.tile_position = tile_pos
			Globals.tile_data_map.set(tile_pos, tile_new)
			tile_new.name = "Hex: { %s, %s }" % [x, z]
			if randi_range(0, 1) < 0.8:
				tile_new.tile_type = "forest"
			tile_new.generate_hexagons(composite_tile_count)
			composite_tile_count += 1

			add_child(tile_new)
		if is_even_row:
			x_shift += 20
			z_shift_odd += 3.5
		else:
			x_shift += 22
			z_shift_even += 3.5
			


		

	
