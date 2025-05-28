extends Node3D

const TILE_WIDTH := 4.0   # flat-to-flat (X)
const TILE_HEIGHT := 4.462  # point-to-point (Z)
const HEX_TILE = preload("res://tile.tscn")
var tile_position : Vector2i
const TILE_DIRT_LARGER = preload("res://tile-dirt-larger.vox")
const TILE_FOREST_LARGER = preload("res://tile-forest-larger.vox")
const TREE = preload("res://tree.tscn")
@export var radius := 3  # Hex radius in tiles (center to any edge)
var base_types : Array
const TILE_TYPES:= ["forest", "grass"]
const HUMAN_ON_TILE_LARGE = preload("res://human.tscn")
const HEXAGON = preload("res://hexagon.glb")
const HEXAGON_RED = preload("res://hexagon-red.glb")

func _ready() -> void:
	base_types = [HEXAGON]
	generate_hexagon()

func generate_hexagon():
	var type = TILE_TYPES.pick_random()
	for q in range(-radius, radius + 1):
		var r1 = max(-radius, -q - radius)
		var r2 = min(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var tile = HEX_TILE.instantiate()
			add_child(tile)
			var mesh_instance = tile.get_node("MeshInstance3D")  # Change the name if needed
			mesh_instance.mesh = base_types.pick_random()
			tile.tile_position = Vector2i(q, r)
			# Convert axial coordinates (q, r) to world coordinates
			var x = TILE_WIDTH * (q + r / 2.0)
			var z = TILE_HEIGHT * (r * 0.666)  # vertical spacing for pointy tops
			if type == "forest":
				var has_tree = randf_range(1, 100)
				if has_tree < 80:
					tile.add_child(TREE.instantiate())
			else:
				var has_tree = randf_range(1, 100)
				if has_tree < 10:
					tile.add_child(TREE.instantiate())
			tile.position = Vector3(x, 0, z)
			
