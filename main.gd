extends Node3D

const GRID_WIDTH:= 5
const GRID_HEIGHT:= 5
var current_tile_position_x = 0
var current_tile_position_z = 0
var row_position = 0
var row_step = 0
const TILE_COMPOSITE = preload("res://tile_composite.tscn")
@onready var camera: Camera3D = $CameraRig/Camera3D

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

	
#Total height = 230
#Total width = 264
func _generate_map():
	for y in GRID_HEIGHT:
		row_position = y * 12
		current_tile_position_x = 0
		for x in GRID_WIDTH:
			var tile_new = TILE_COMPOSITE.instantiate()
			current_tile_position_z = 0 if x % 2 == 0 else 8 
			tile_new.position.x = current_tile_position_x
			tile_new.position.z = row_position + current_tile_position_z
			tile_new.tile_position = Vector2i(x,y)
			self.add_child(tile_new)
			current_tile_position_x += 12
