extends Node

var inner_tile_positions = [
	Vector2i(0,0),
	Vector2i(0,1),
	Vector2i(0,2),
	Vector2i(0,3),
	Vector2i(0,-1),
	Vector2i(0,-2),
	Vector2i(0,-3),
	Vector2i(-1,-2),
	Vector2i(-1,-1),
	Vector2i(-1,0),
	Vector2i(-1,1),
	Vector2i(-1,2),
	Vector2i(-1,3),
	Vector2i(-2,-1),
	Vector2i(-2,0),
	Vector2i(-2,1),
	Vector2i(-2,2),
	Vector2i(-2,3),
	Vector2i(-3,0),
	Vector2i(-3,1),
	Vector2i(-3,2),
	Vector2i(-3,3),
	Vector2i(1,-3),
	Vector2i(1,-2),
	Vector2i(1,-1),
	Vector2i(1,-0),
	Vector2i(1,-1),
	Vector2i(1,-2),
	Vector2i(2,-3),
	Vector2i(2,-2),
	Vector2i(2,-1),
	Vector2i(2,-0),
	Vector2i(2,1),
	Vector2i(3,-3),
	Vector2i(3,-3),
	Vector2i(3,-2),
	Vector2i(3,-1),
	Vector2i(3, 0),
]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_handle_click(event.position)

func _handle_click(screen_position: Vector2) -> void:
	var camera := Globals.selected_camera
	if not camera:
		return
		
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * 1000.0

	var space_state := get_viewport().get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Adjust if needed

	var result := space_state.intersect_ray(query)
	if result:
		var target = result["collider"].tile_position
		_move_unit_to_tile(Globals.selected_unit, target)

func _move_unit_to_tile(unit: Node3D, outer_coord: Vector2i) -> void:
	var pathfinder = Pathfinder.new()
	var inner_coord = Vector2i(0,0)
	var path = pathfinder.get_composite_path(unit.inner_tile_position, unit.outer_tile_position, outer_coord, inner_coord)
	for tile in path[0]:
		unit.inner_tile_position = tile
		
	unit.outer_tile_position = outer_coord
	
	for tile in path[1]:
		unit.inner_tile_position = tile
