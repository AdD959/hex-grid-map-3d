extends Node3D

const GRID_WIDTH:= 15
const GRID_HEIGHT:= 15
var current_tile_position_x = 0
var current_tile_position_z = 0
var row_position = 0
var row_step = 0
const TILE_COMPOSITE = preload("res://tile_composite.tscn")
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var camera_3d_2: Camera3D = $CameraRig/Camera3D2

func _ready() -> void:
	_generate_map()
	
func _generate_map():
	var tile_width = 20   # Distance between centers horizontally (flat-top hex)
	var tile_height = 21.2     # Distance between centers vertically (row spacing)
	var z_offset = 12     # Extra vertical offset for odd X columns (staggered effect)
	var row_x_indent = -2.0     # Cumulative indent per row on the X axis

	for x in GRID_WIDTH:
		for z in GRID_HEIGHT:
			var tile_new = TILE_COMPOSITE.instantiate()

			# Start X position with base horizontal spacing
			var x_pos = x * tile_width
			# Add cumulative X shift per row (Z index)
			x_pos += z * row_x_indent

			# Calculate Z position and apply offset to odd columns
			var z_pos = z * tile_height
			if x % 2 != 0:
				z_pos += z_offset

			tile_new.position = Vector3(
				x_pos,
				0,       # Y is not used in positioning
				z_pos
			)

			tile_new.tile_position = Vector2i(x, z)
			add_child(tile_new)
