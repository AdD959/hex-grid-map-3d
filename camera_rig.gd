extends Node3D

@export var drag_sensitivity := 10.0
@export var zoom_sensitivity := 2.0
@export var min_zoom := 5.0
@export var max_zoom := 50.0

var is_dragging := false
var last_mouse_position := Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				last_mouse_position = event.position

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(-zoom_sensitivity)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(zoom_sensitivity)

	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - last_mouse_position
		last_mouse_position = event.position

		# Isometric movement vectors
		var right := Vector3(1, 0, -1).normalized()
		var forward := Vector3(1, 0, 1).normalized()

		var movement = (-right * delta.x + -forward * delta.y) * drag_sensitivity * 0.01
		translate(movement)
		
func _zoom_camera(amount: float):
	if Globals.selected_camera:
		Globals.selected_camera.size += amount
