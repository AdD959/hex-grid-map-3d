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
		_move_unit_to_outer_tile(Globals.selected_unit, target)


func _move_unit_to_outer_tile(unit: Node3D, outer_coord: Vector2i) -> void:
	var tile_data = Globals.tile_data_map.get(outer_coord)
	if tile_data:
		var inner_tile_data = tile_data.inner_tiles_data_map.get(Vector2i(0, 0), null)
		if inner_tile_data:
			print("moving to: ", inner_tile_data)
			var target_position = inner_tile_data

			# If there’s already a tween running on this unit, kill it:
			if unit.has_meta("active_tween"):
				var old_tween = unit.get_meta("active_tween")
				old_tween.kill()

			# Create a new tween, animate the position over 0.5s:
			var tween = get_tree().create_tween()
			tween.tween_property(unit, "position", target_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

			# Store the reference so we can cancel it next time:
			unit.set_meta("active_tween", tween)
