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
	
#func _input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#var mouse_pos = event.position
		#var from = camera.project_ray_origin(mouse_pos)
#
		#var space_state = get_world_3d().direct_space_state
		#var result = space_state.intersect_ray(from)
#
		#if result:
			#var click_position = result.position
			#print("Mouse clicked at 3D position: ", click_position)

#Y axis
#y/z dfference = 21.2
#x difference = 2 (odd rows) 0 on even

#X AXIS
#x axis : y/z of 8.915
#y axis: 22.001

#so on x axis, I need to be at either 8.915 or 0 on y/z and then push by 22.001 on x
#for Y axis I need to be at either 2 or 0 on x axis, and push by 21.2 on y

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

			print("x: %s z: %s" % [x, z])
			print("x-pos: %.2f z-pos: %.2f" % [tile_new.position.x, tile_new.position.z])



			
	#for z in GRID_HEIGHT:
		#row_position = z * 13.9
		#current_tile_position_x = -1.197 if z % 2 == 0 else 0
		#for x in GRID_WIDTH:
			#var tile_new = TILE_COMPOSITE.instantiate()
			#current_tile_position_z = 0 if x % 2 == 0 else 6
			#tile_new.position.x = current_tile_position_x
			#tile_new.position.z = row_position + current_tile_position_z
			#tile_new.tile_position = Vector2i(x,z)
			#self.add_child(tile_new)
			#current_tile_position_x += 13.197
