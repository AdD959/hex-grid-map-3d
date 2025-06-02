class_name HexPathfinder
extends Node

var g_score := {}  # Cost from start to tile
var f_score := {}  # Estimated total cost

# Finds the shortest path between start and end in a hex grid
func find_path(start: Vector2i, end: Vector2i) -> Array:
	var open_set = [start]  # Tiles to explore
	var came_from = {}  # Dictionary to track movement history
	g_score.clear()
	f_score.clear()

	g_score[start] = 0
	f_score[start] = heuristic(start, end)

	while open_set.size() > 0:
		open_set.sort_custom(Callable(self, "compare_f_score"))  # Sort by lowest f_score
		var current = open_set.pop_front()

		if current == end:
			return reconstruct_path(came_from, current, start)

		for neighbor in Globals.base_tiles_map.get_surrounding_cells(current):
			var tentative_g_score = g_score.get(current, INF) + 1  # Each move has a cost of 1

			if tentative_g_score < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + heuristic(neighbor, end)
				if not neighbor in open_set:
					open_set.append(neighbor)

	return []  # No path found

# Hexagonal distance heuristic
func heuristic(a: Vector2i, b: Vector2i) -> int:
	return max(abs(a.x - b.x), abs(a.y - b.y))  # Manhattan heuristic for hex grids

# Compare function for sorting open_set by f_score
func compare_f_score(a: Vector2i, b: Vector2i) -> bool:
	return f_score.get(a, INF) < f_score.get(b, INF)

# Reconstructs the path from start to end, excluding the starting tile
func reconstruct_path(came_from: Dictionary, current: Vector2i, start: Vector2i) -> Array:
	var path = []
	while current in came_from:
		path.append(current)
		current = came_from[current]
	path.reverse()
	
	# Ensure the starting position is not included
	if path.size() > 0 and path[0] == start:
		path.remove_at(0)
	
	return path
