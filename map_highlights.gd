extends Node3D

const GRID_WIDTH := 5
const GRID_HEIGHT := 5
const HIGHLIGHT_SCENE = preload("res://highlight_scene.tscn")

var highlight_tiles: Array = []
@onready var camera: Camera3D = $"../CameraRig/Camera3D"
@onready var camera_3d_2: Camera3D = $"../CameraRig/Camera3D2"

func _ready() -> void:
	#_generate_map()
	pass

func _generate_map():
	for y in GRID_HEIGHT:
		var row_position = y * 12
		var current_tile_position_x = 0
		for x in GRID_WIDTH:
			var tile_new = HIGHLIGHT_SCENE.instantiate()
			var current_tile_position_z = 0 if x % 2 == 0 else 8 
			tile_new.position.x = current_tile_position_x
			tile_new.position.z = row_position + current_tile_position_z
			tile_new.position.y = 1
			tile_new.tile_position = Vector2i(x, y)
			tile_new.visible = false  # Start hidden
			self.add_child(tile_new)
			highlight_tiles.append(tile_new)
			current_tile_position_x += 12

var last_hovered_tile: Node3D = null

func _process(delta: float) -> void:
	if camera_3d_2 == null:
		return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera_3d_2.project_ray_origin(mouse_pos)
	var ray_direction = camera_3d_2.project_ray_normal(mouse_pos)
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_origin + ray_direction * 1000
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	var hovered_tile: Node3D = null
	if result and result.has("collider"):
		hovered_tile = result["collider"]

	if hovered_tile != last_hovered_tile:
		# Hide the last one
		if last_hovered_tile != null:
			last_hovered_tile.visible = false
		# Show the new one
		if hovered_tile != null:
			hovered_tile.visible = true
		last_hovered_tile = hovered_tile
