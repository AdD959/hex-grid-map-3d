extends Button


func _on_pressed() -> void:
	if Globals.selected_camera == Globals.camera_isometric:
		Globals.selected_camera = Globals.camera_top_down
		Globals.selected_camera.position = Globals.camera_isometric.position
		Globals.selected_camera.size = Globals.camera_isometric.size
	else:
		Globals.selected_camera = Globals.camera_isometric
		Globals.selected_camera.position = Globals.camera_top_down.position
		Globals.selected_camera.size = Globals.camera_top_down.size
		
	Globals.selected_camera.current = true
