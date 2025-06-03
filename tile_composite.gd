extends Node3D

const TILE_WIDTH := 4.0   # flat-to-flat (X)
const TILE_HEIGHT := 4.462  # point-to-point (Z)
@export var radius := 3  # Hex radius in tiles (center to any edge)
var tile_type: String
var tile_position: Vector2i
var inner_tiles_data_map = {}
var base_types: Array = []
var tile_types = {
	"grass": Globals.grass_tile.multimesh,
	"dark_grass": Globals.dark_grass_tile.multimesh,
}
var tile_index:= 0
var hex_index:= 0

	
func add_multimesh_instance(type: String, transform: Transform3D):
	Globals.tile_instance_refences[type] = transform
	
	var mm = tile_types[type]
	var index = Globals.multimesh_instance_indices[type]
	# Safely expand instance count if needed

	mm.set_instance_transform(index, transform)
	# This should be true:

	Globals.multimesh_instance_indices[type] += 1
	
func generate_hexagons(composite_tile_index: int):
	tile_index = composite_tile_index * 37
	for q in range(-radius, radius + 1):
		var r1 = max(-radius, -q - radius)
		var r2 = min(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var x = TILE_WIDTH * (q + r / 2.0)
			var z = TILE_HEIGHT * (r * 0.75)
			var pos_3d_world = Vector3(x + position.x, 0, z + position.z)
			var current_index = tile_index + hex_index
			hex_index += 1 
			
			# Add terrain tile
			var base_transform = Transform3D(Basis(), pos_3d_world)
			var type = ["grass", "dark_grass"].pick_random()
			add_multimesh_instance(type, base_transform)
			inner_tiles_data_map[Vector2i(q, r)] = { "position" : Vector3(x, 0 ,z), "tree": false }

			# Create 3D label and place it just above the tile
			var label_3d := Label3D.new()
			label_3d.text = "(%d, %d)" % [q, r]
			label_3d.position = Vector3(x,1,z)  # 1.0 units above tile
			label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED  # Optional: lock rotation
			label_3d.modulate = Color(1, 1, 1)  # White text
			label_3d.font_size = 64  # Optional: depends on your font resource
			label_3d.no_depth_test = true

			add_child(label_3d)
			
			# If forest, maybe place a tree
			if tile_position == Vector2i(1,1):
				if randf() < 2.0:
					var scale = randf_range(0.7, 1.0)
					var rotation = randf_range(0, TAU)  # TAU = 2 * PI
					
					# Rotate around Y-axis (vertical in Godot 3D)
					var rotation_basis = Basis(Vector3.UP, rotation)
					# Apply uniform scaling using a scale matrix
					var scale_basis = Basis()
					scale_basis.x *= scale
					scale_basis.y *= scale
					scale_basis.z *= scale

					# Combine rotation and scale
					var final_basis = rotation_basis * scale_basis

					var tree_transform = Transform3D(final_basis, pos_3d_world)
					Globals.tree_2_multimesh.multimesh.set_instance_transform(current_index, tree_transform)
					inner_tiles_data_map[Vector2i(q, r)]["tree"] = true
					
	
			if tile_position == Vector2i(3,1) or tile_position == Vector2i(2,1):
				if randf() < 0.7:
					var scale = randf_range(0.7, 1.0)
					var rotation = randf_range(0, TAU)  # TAU = 2 * PI
					
					# Rotate around Y-axis (vertical in Godot 3D)
					var rotation_basis = Basis(Vector3.UP, rotation)
					# Apply uniform scaling using a scale matrix
					var scale_basis = Basis()
					scale_basis.x *= scale
					scale_basis.y *= scale
					scale_basis.z *= scale

					# Combine rotation and scale
					var final_basis = rotation_basis * scale_basis

					var tree_transform = Transform3D(final_basis, pos_3d_world)
					Globals.tree_2_multimesh.multimesh.set_instance_transform(current_index, tree_transform)
					inner_tiles_data_map[Vector2i(q, r)]["tree"] = true
