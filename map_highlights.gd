extends Node3D

const HIGHLIGHT_SCENE = preload("res://highlight_scene.tscn")

var highlight_tiles: Array = []

func _ready() -> void:
	_generate_map()

func _generate_map():
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
			add_child(tile_new)
		if is_even_row:
			x_shift += 20
			z_shift_odd += 3.5
		else:
			x_shift += 22
			z_shift_even += 3.5

var last_hovered_tile: Node3D = null

func _process(delta: float) -> void:
	if Globals.selected_camera == null:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = Globals.selected_camera.project_ray_origin(mouse_pos)
	var ray_direction = Globals.selected_camera.project_ray_normal(mouse_pos)
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_origin + ray_direction * 1000
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	var hovered_tile: Node3D = null
	if result and result.has("collider"):
		hovered_tile = result["collider"]
	

	if hovered_tile != last_hovered_tile and hovered_tile != null:
		var current_unit_tile = Globals.selected_unit._outer_tile_position
		var direction = HexPathfinder.get_hex_direction(current_unit_tile, hovered_tile.tile_position)
		var tile_moveable = HexPathfinder.entry_and_exits_are_free(current_unit_tile, hovered_tile.tile_position, direction)

		# Hide the last one
		if last_hovered_tile != null:
			last_hovered_tile.visible = false

		# Show and color the new one
		if hovered_tile != null:
			hovered_tile.visible = true
			var visual_node = hovered_tile.get_node("hexagon-highlight") # Adjust name if different
			var visual_mesh = visual_node.get_node("Cylinder_032")

			# Try to get mesh instance and change its material
			if visual_mesh and visual_mesh is MeshInstance3D:
				var mesh = visual_mesh as MeshInstance3D
				var material := mesh.get_surface_override_material(0)

				if material == null:
					material = StandardMaterial3D.new()
					mesh.set_surface_override_material(0, material)
				if tile_moveable:
					material.albedo_color = Color(1, 0, 0)  # Red
				else:
					material.albedo_color = Color(1, 1, 1) # White

		last_hovered_tile = hovered_tile
