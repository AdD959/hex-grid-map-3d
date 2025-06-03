extends Node

class_name Pathfinder

# Assumes inner_tile_positions defines traversable tiles
var inner_tile_positions: Array[Vector2i] = [
	Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,-1), Vector2i(0,-2), Vector2i(0,-3),
	Vector2i(-1,-2), Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(-1,2), Vector2i(-1,3),
	Vector2i(-2,-1), Vector2i(-2,0), Vector2i(-2,1), Vector2i(-2,2), Vector2i(-2,3),
	Vector2i(-3,0), Vector2i(-3,1), Vector2i(-3,2), Vector2i(-3,3),
	Vector2i(1,-3), Vector2i(1,-2), Vector2i(1,-1), Vector2i(1,0), Vector2i(2,-3), Vector2i(2,-2),
	Vector2i(2,-1), Vector2i(2,0), Vector2i(2,1), Vector2i(3,-3), Vector2i(3,-2), Vector2i(3,-1), Vector2i(3, 0),
]

# Directions for hex grid neighbors (pointy-top, axial coords)
const HEX_DIRECTIONS = [
	Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, -1),
]

const INNER_EDGE_MAP = {
	"NE": [Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3)],
	"E":  [Vector2i(3, -3), Vector2i(3, -2), Vector2i(3, -1), Vector2i(3, 0)],
	"SE": [Vector2i(3, 0), Vector2i(2, 1), Vector2i(1, 2), Vector2i(0, 3)],
	"SW": [Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3)],
	"W":  [Vector2i(-3, 0), Vector2i(-3, 1), Vector2i(-3, 2), Vector2i(-3, 3)],
	"NW": [Vector2i(0, -3), Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-3, 0)]
}

func entry_and_exits_are_free(from_outer: Vector2i, to_outer: Vector2i, direction: String) -> bool:
	var blocked = false
	var entry_points = INNER_EDGE_MAP.get(get_opposite_direction(direction), [])
	var exit_points = INNER_EDGE_MAP.get(direction, [])
	if paths_are_blocked(entry_points, to_outer) or paths_are_blocked(exit_points, from_outer):
		blocked = true
	return blocked

func get_composite_path(from_inner: Vector2i, from_outer: Vector2i, to_outer: Vector2i, to_inner: Vector2i) -> Array[Array]:
	var direction := get_hex_direction(from_outer, to_outer)
	var entry_points = INNER_EDGE_MAP.get(get_opposite_direction(direction), [])
	if paths_are_blocked(entry_points, to_outer):
		push_error("No entry points for direction: " + direction)
		return []
	if entry_points.is_empty():
		push_error("No entry points for direction: " + direction)
		return []

	var exit_points = INNER_EDGE_MAP.get(direction, [])

	var target_entry = entry_points[1]
	var target_exit = exit_points[1]

	# A* from current inner tile to the exit tile (avoid trees)
	var current_tile_path = run_astar(from_inner, target_exit, from_outer)

	# Find best reachable tile in next composite (avoid trees)
	var destination_inner = find_closest_reachable_inner_tile(to_outer, target_entry, to_inner)

	if destination_inner == null:
		return []

	# A* into next tile (avoid trees)
	var next_tile_path = run_astar(target_entry, destination_inner, to_outer)

	# If either path is empty, it's blocked
	if current_tile_path.is_empty() or next_tile_path.is_empty():
		return []

	return [current_tile_path, next_tile_path]


func is_tile_walkable(outer_tile: Vector2i, inner_tile: Vector2i) -> bool:
	var data = Globals.tile_data_map.get(outer_tile, null)
	if data and data.inner_tiles_data_map.has(inner_tile):
		return not data.inner_tiles_data_map[inner_tile].get("tree", false)
	return false

func paths_are_blocked(tiles: Array[Variant], outer_composite: Vector2i) -> bool:
	for tile in tiles:
		if is_tile_walkable(outer_composite, tile):
			return false
	return true

func find_closest_reachable_inner_tile(outer_tile: Vector2i, from_inner: Vector2i, target_inner: Vector2i) -> Variant:
	var data = Globals.tile_data_map.get(outer_tile, null)
	if data == null:
		return null

	var all_tiles = data.inner_tiles_data_map.keys()
	var walkable_tiles = []
	for tile in all_tiles:
		if is_tile_walkable(outer_tile, tile):
			walkable_tiles.append(tile)

	# Sort by closeness to the central tile (usually 0,0)
	walkable_tiles.sort_custom(func(a, b): return a.distance_squared_to(target_inner) < b.distance_squared_to(target_inner))

	for tile in walkable_tiles:
		var path = run_astar(from_inner, tile, outer_tile)
		if path.size() > 0:
			return tile  # First reachable walkable tile

	return null

func run_astar(start: Vector2i, goal: Vector2i, outer_tile: Variant = null) -> Array[Vector2i]:
	var open_set: Array[Vector2i] = [start]
	var came_from = {}
	var g_score = {start: 0}
	var f_score = {start: start.distance_to(goal)}

	while not open_set.is_empty():
		open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
		var current = open_set[0]
		if current == goal:
			return reconstruct_path(came_from, current)

		open_set.remove_at(0)
		for neighbor in get_neighbors(current):
			if outer_tile and not is_tile_walkable(outer_tile, neighbor):
				continue  # Skip tiles with trees
			
			var tentative_g = g_score.get(current, INF) + 1
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + neighbor.distance_to(goal)
				if not neighbor in open_set:
					open_set.append(neighbor)

	return []  # No valid path


func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while current in came_from:
		current = came_from[current]
		path.insert(0, current)
	return path

func get_neighbors(tile: Vector2i) -> Array[Vector2i]:
	var results: Array[Vector2i] = []
	for dir in HEX_DIRECTIONS:
		var neighbor = tile + dir
		if neighbor in inner_tile_positions:
			results.append(neighbor)
	return results

func get_hex_direction(from: Vector2i, to: Vector2i) -> String:
	var is_even_row = true if from.x % 2 == 0 else false
	var diff = to - from
	if is_even_row:
		match diff:
			Vector2i(1, -1): return "E"
			Vector2i(1, 0): return "SE"
			Vector2i(0, 1): return "SW"
			Vector2i(-1, 0): return "W"
			Vector2i(-1, -1): return "NW"
			Vector2i(0, -1): return "NE"
			_: return "E" # fallback
	else:
		match diff:
			Vector2i(1, 0): return "E"
			Vector2i(1, 1): return "SE"
			Vector2i(0, 1): return "SW"
			Vector2i(-1, 1): return "W"
			Vector2i(-1, 0): return "NW"
			Vector2i(0, -1): return "NE"
			_: return "E" # fallback

func get_opposite_direction(dir: String) -> String:
	return {
		"E": "W", "W": "E",
		"NE": "SW", "SW": "NE",
		"NW": "SE", "SE": "NW"
	}.get(dir, "W")
