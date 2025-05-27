extends GridMap

const TILE_WIDTH := 16.8   # Total flat-to-flat width
const TILE_HEIGHT := 15.75 # Total point-to-point height
const HIGHLIGHT_SCENE = preload("res://highlight_scene.tscn")
@onready var camera: Camera3D = $"../CameraRig/Camera3D"

var mesh_instance: MeshInstance3D
var tile: Node3D

#func _ready() -> void:
	#spawn_large_hex_tile()

func spawn_large_hex_tile():
	tile = HIGHLIGHT_SCENE.instantiate()
	add_child(tile)

	mesh_instance = tile.get_node("MeshInstance3D")  # Adjust node name if needed
	if mesh_instance:
		var mesh_size = mesh_instance.mesh.get_aabb().size
		if mesh_size.x != 0 and mesh_size.z != 0:
			var scale_x = TILE_WIDTH / mesh_size.x
			var scale_z = TILE_HEIGHT / mesh_size.z
			var scale_y = 10
			mesh_instance.scale = Vector3(scale_x, scale_y, scale_z)
		else:
			push_warning("Mesh size is zero; check mesh setup.")
	else:
		push_error("MeshInstance3D not found in tile scene.")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tile_clicked = handle_click(event.position)

func handle_click(screen_pos: Vector2) -> Vector3:
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_direction = camera.project_ray_normal(screen_pos)
	var ray_end = ray_origin + ray_direction * 1000.0
	var ray_params = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var ray_result = get_world_3d().direct_space_state.intersect_ray(ray_params)

	var hit_position = ray_result.get("position", Vector3.ZERO)
	return hit_position
