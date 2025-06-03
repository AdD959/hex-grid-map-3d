extends Node3D
const HIGHLIGHT_SCENE = preload("res://highlight_scene.tscn")
var highlight_tiles: Array = []

# Optimization variables
var hover_debounce_timer: float = 0.0
var last_mouse_pos: Vector2 = Vector2.ZERO
var path_cache: Dictionary = {}
var moveable_material: StandardMaterial3D
var non_moveable_material: StandardMaterial3D
var last_hovered_tile: Node3D = null

const HOVER_DEBOUNCE_TIME: float = 0.05  # 50ms delay
const MAX_CACHE_SIZE: int = 1000

func _ready() -> void:
	# Pre-create materials to avoid garbage collection
	moveable_material = StandardMaterial3D.new()
	moveable_material.albedo_color = Color(1, 1, 1)  # White
	
	non_moveable_material = StandardMaterial3D.new()
	non_moveable_material.albedo_color = Color(1, 0, 0)  # Red
	
	generate_map()

func generate_map():
	var tile_width = 28   # Distance between centers horizontally (flat-top hex)
	var tile_height = 24.7     # Distance between centers vertically (row spacing)
	
	var x_shift = 0
	var z_shift = 0
	var z_shift_odd = 10
	var z_shift_even = 0
	for x in range(Globals.GRID_WIDTH):
		var is_even_row = true if x % 2 == 0 else false
		for z in range(Globals.GRID_HEIGHT):
			var tile_new = HIGHLIGHT_SCENE.instantiate()
			tile_new.visible = false
			var z_axis_z_offset = 23.5
			var z_axis_x_offset = -2 
			var x_axis_z_offset = 3.5 # BUT even rows also have an additional 13.5 (or maybe just starts at 13.5 then accumulated 3.5) 
			var x_axis_x_offset = 22 # BUT even rows are 20
			
			var x_pos = (-2.0 * z) + x_shift
			var z_pos = 23.5 * z
			
			tile_new.position = Vector3(
				x_pos,
				0.1,       # Y is not used in positioning
				z_pos + z_shift_even if x % 2 == 0 else z_pos + z_shift_odd
			)
			
			tile_new.tile_position = Vector2i(x, z)
			tile_new.name = "Hex: { %s, %s }" % [x, z]
			
			# Cache the mesh reference to avoid repeated get_node() calls
			var visual_mesh = tile_new.get_node("hexagon-highlight/Cylinder_032")
			if visual_mesh:
				tile_new.set_meta("cached_mesh", visual_mesh)
			
			add_child(tile_new)
		if is_even_row:
			x_shift += 20
			z_shift_odd += 3.5
		else:
			x_shift += 22
			z_shift_even += 3.5

func get_cached_path(from_inner: Vector2i, from_outer: Vector2i, to_outer: Vector2i, to_inner: Vector2i) -> Array:
	var cache_key = str(from_inner) + "|" + str(from_outer) + "|" + str(to_outer) + "|" + str(to_inner)
	
	if cache_key in path_cache:
		return path_cache[cache_key]
	
	var path = HexPathfinder.get_composite_path(from_inner, from_outer, to_outer, to_inner)
	path_cache[cache_key] = path
	
	# Limit cache size to prevent memory bloat
	if path_cache.size() > MAX_CACHE_SIZE:
		path_cache.clear()
	
	return path

func _process(delta: float) -> void:
	# Early exits
	if Globals.selected_camera == null or Globals.selected_unit == null:
		return
	
	# Debounce hover processing
	hover_debounce_timer -= delta
	if hover_debounce_timer > 0:
		return
	
	# Check if mouse moved
	var current_mouse_pos = get_viewport().get_mouse_position()
	if current_mouse_pos == last_mouse_pos:
		return
	last_mouse_pos = current_mouse_pos
	
	# Raycast to find hovered tile
	var ray_origin = Globals.selected_camera.project_ray_origin(current_mouse_pos)
	var ray_direction = Globals.selected_camera.project_ray_normal(current_mouse_pos)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_origin + ray_direction * 1000
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	var hovered_tile: Node3D = null
	if result and result.has("collider"):
		hovered_tile = result["collider"]
	
	# Only process if we're hovering over a different tile
	if hovered_tile == last_hovered_tile:
		return
	
	# Set debounce timer BEFORE processing to prevent rapid calls
	hover_debounce_timer = HOVER_DEBOUNCE_TIME
	
	# Hide the previously hovered tile
	if last_hovered_tile != null:
		last_hovered_tile.visible = false
	
	# Process new hovered tile
	if hovered_tile != null:
		# Get path and determine if tile is moveable
		var path = get_cached_path(
			Globals.selected_unit.inner_tile_position,
			Globals.selected_unit._outer_tile_position,
			hovered_tile.tile_position,
			Vector2i(0,0)
		)
		
		var tile_moveable = path.size() >= 1
		
		# Show and color the hovered tile
		hovered_tile.visible = true
		
		# Use cached mesh reference
		var visual_mesh = hovered_tile.get_meta("cached_mesh", null)
		if visual_mesh and visual_mesh is MeshInstance3D:
			var mesh = visual_mesh as MeshInstance3D
			if tile_moveable:
				mesh.set_surface_override_material(0, moveable_material)
			else:
				mesh.set_surface_override_material(0, non_moveable_material)
	
	# Update last hovered tile
	last_hovered_tile = hovered_tile
