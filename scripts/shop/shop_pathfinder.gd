class_name ShopPathfinder
extends RefCounted


static func find_path(grid: ShopGrid, from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	if grid == null:
		return []
	var start := grid.nearest_walkable(from)
	var goal := grid.nearest_walkable(to)
	if start.x < 0 or goal.x < 0:
		return []
	if start == goal:
		return [start]
	var came_from: Dictionary = {}
	var cost: Dictionary = {}
	var open: Array[Vector2i] = [start]
	cost[start] = 0
	while not open.is_empty():
		var current := _pop_closest(open, cost, goal)
		if current == goal:
			return _rebuild(came_from, start, goal)
		for neighbor: Vector2i in grid.neighbors(current):
			if not grid.is_walkable(neighbor):
				continue
			var next_cost: int = int(cost[current]) + 1
			if cost.has(neighbor) and next_cost >= int(cost[neighbor]):
				continue
			cost[neighbor] = next_cost
			came_from[neighbor] = current
			if neighbor not in open:
				open.append(neighbor)
	return []


static func world_path(grid: ShopGrid, from: Vector3, to: Vector3) -> Array[Vector3]:
	var tiles := find_path(grid, grid.world_to_tile(from), grid.world_to_tile(to))
	var points: Array[Vector3] = []
	for tile: Vector2i in tiles:
		points.append(grid.tile_to_world(tile))
	return points


static func _pop_closest(
	open: Array[Vector2i],
	cost: Dictionary,
	goal: Vector2i
) -> Vector2i:
	var best_index := 0
	var best_score := 1_000_000
	for index: int in open.size():
		var tile: Vector2i = open[index]
		var score: int = int(cost[tile]) + _manhattan(tile, goal)
		if score < best_score:
			best_score = score
			best_index = index
	var chosen: Vector2i = open[best_index]
	open.remove_at(best_index)
	return chosen


static func _rebuild(
	came_from: Dictionary,
	start: Vector2i,
	goal: Vector2i
) -> Array[Vector2i]:
	var path: Array[Vector2i] = [goal]
	var cursor := goal
	while cursor != start:
		cursor = came_from[cursor]
		path.push_front(cursor)
	return path


static func _manhattan(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
