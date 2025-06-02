extends Node

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

const INNER_EDGE_MAP = {
	"NE": [Vector2i(3, 0), Vector2i(4, 1)],
	"E":  [Vector2i(6, 3), Vector2i(5, 4)],
	"SE": [Vector2i(4, 5), Vector2i(3, 6)],
	"SW": [Vector2i(2, 6), Vector2i(1, 5)],
	"W":  [Vector2i(0, 3), Vector2i(1, 2)],
	"NW": [Vector2i(1, 1), Vector2i(2, 0)]
}

func _move_unit_to_tile(unit: Node3D, outer_coord: Vector2i) -> void:
	unit.outer_tile_position = Vector2i(0,1)
	unit.inner_tile_position = Vector2i(0, 3)
	
	
	var tile_data = Globals.tile_data_map.get(outer_coord)
	var inner_tile_data = tile_data.inner_tiles_data_map.get(Vector2i(0, 0), null)
	var target_position = inner_tile_data
	var direction = get_hex_direction(unit.outer_tile_position, outer_coord)
	
	#unit.outer_tile_position = outer_coord
	#unit.inner_tile_position = Vector2i(0, 0)
	#print(unit.outer_tile_position)
	#print(unit.inner_tile_position)
	#var path = createPathfinder(Vector2i(0, 0), outer_coord)
	#_move_unit_along_composite_path(unit, path)
	#print(unit.outer_tile_position)
	#print(unit.position)
	### If there’s already a tween running on this unit, kill it:
	#if unit.has_meta("active_tween"):
		#var old_tween = unit.get_meta("active_tween")
		#old_tween.kill()
#
	## Create a new tween, animate the position over 0.5s:
	#var tween = get_tree().create_tween()
	#tween.tween_property(unit, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
#
	## Store the reference so we can cancel it next time:
	#unit.set_meta("active_tween", tween)
	

	
func createPathfinder(start_tile: Vector2i, end_tile: Vector2i) -> Array[Vector2i]:
	return [Vector2i(0, 1), Vector2i(-1, 0)]

func _move_unit_along_composite_path(unit: Node3D, composite_path: Array[Vector2i]) -> void:
	if composite_path.size() < 2:
		return

	if unit.has_meta("active_tween"):
		var old_tween = unit.get_meta("active_tween")
		old_tween.kill()

	var tween = get_tree().create_tween()
	var previous_composite = composite_path[0]
	var current_inner_tile = Vector2i(0, 0) # Assume center starting point

	for i in range(1, composite_path.size()):
		var next_composite = composite_path[i]
		var dir = get_hex_direction(previous_composite, next_composite)
		
		print(Globals.tile_data_map[Vector2i(0,1)].inner_tiles_data_map.keys())
		var destination = Globals.tile_data_map[Vector2i(0,1)].inner_tiles_data_map[Vector2i(6,3)]
		 #Exit point in current tile
		tween.tween_property(unit, "position", destination, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
#
		## Entry point in next tile
		#var entry_tiles = INNER_EDGE_MAP[get_opposite_direction(dir)]
		#var entry_pos = get_inner_tile_world_pos(next_composite, entry_tiles[0])
		#tween.tween_property(unit, "position", entry_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
#
		## Optional: move to center of next composite tile
		#var center_pos = get_inner_tile_world_pos(next_composite, Vector2i(3, 3))
		#tween.tween_property(unit, "position", center_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		previous_composite = next_composite

	unit.set_meta("active_tween", tween)

func get_hex_direction(from: Vector2i, to: Vector2i) -> String:
	var diff = to - from
	match diff:
		Vector2i(1, 0): return "E"
		Vector2i(0, -1): return "NE"
		Vector2i(-1, 0): return "NW"
		Vector2i(-1, 1): return "W"
		Vector2i(0, 1): return "SW"
		Vector2i(1, 1): return "SE"
		_: return "E" # default fallback

func get_opposite_direction(dir: String) -> String:
	return {
		"E": "W",
		"NE": "SW",
		"NW": "SE",
		"W": "E",
		"SW": "NE",
		"SE": "NW"
	}.get(dir, "W") # default fallback
