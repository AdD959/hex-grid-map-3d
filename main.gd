extends Node3D

const GRID_WIDTH:= 15
const GRID_HEIGHT:= 15
var current_tile_position_x = 0
var current_tile_position_z = 0
var row_position = 0
var row_step = 0
const TILE_COMPOSITE = preload("res://tile_composite.tscn")
@onready var camera_isometric: Camera3D = $CameraRig/CameraIsometric
@onready var camera_top_down: Camera3D = $CameraRig/CameraTopDown

func _ready() -> void:
	Globals.camera_isometric = camera_isometric
	Globals.camera_top_down = camera_top_down
	Globals.cameras = [Globals.camera_isometric, Globals.camera_top_down]
	Globals.selected_camera = Globals.camera_isometric
	Globals.selected_camera.current = true
	
	_generate_map()
	
func _generate_map():
	var tile_width = 28   # Distance between centers horizontally (flat-top hex)
	var tile_height = 24.7     # Distance between centers vertically (row spacing)
	
	var x_shift = 0
	var z_shift = 0
	var z_shift_odd = 10
	var z_shift_even = 0
	for x in range(GRID_WIDTH):
		var is_even_row = true if x % 2 == 0 else false
		for z in range(GRID_HEIGHT):
			var tile_new = TILE_COMPOSITE.instantiate()
			
			#each odd column has an offset of 13.5 (z) from its sibling even columns on the x axis
			#actually, each TILE has z offset of 13.5 (z) from its sibling above it regardless of the even / odd
			#actually, the column before has a z difference of 10, 13.5 to the sequential column
			#each odd column has an offset of 20 (x) from its sibling even column
			#each below hex has an x of -2 compared to the above
			
			
			#x row values:
				#0,0 - 20,13.5, - 42,3.5, - 62, 17, - 84, 7 -  104, 20.5 - 126, 10.5
			#z row values:
#				0,0 - -2, 23.5, -4, 47

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
			
			tile_new.tile_position = Vector2i(x, z)
			tile_new.name = "Hex: { %s, %s }" % [x, z]
			add_child(tile_new)
		if is_even_row:
			x_shift += 20
			z_shift_odd += 3.5
		else:
			x_shift += 22
			z_shift_even += 3.5
			
			
	
