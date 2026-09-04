class_name ShopGrid
extends RefCounted

## Small-shop tile map. Origin is the SW floor corner; +X right, −Z into the shop.
const TILE_SIZE := 0.9

var width: int = ShopState.SMALL_GRID_WIDTH
var height: int = ShopState.SMALL_GRID_HEIGHT
var tile_size: float = TILE_SIZE
var blocked: Dictionary = {}
var entrance_tile: Vector2i = Vector2i(4, 0)
var desk_tile: Vector2i = Vector2i(6, 1)
var browse_tiles: Array[Vector2i] = []
var queue_tiles: Array[Vector2i] = []
var desk_aabb: AABB = AABB(Vector3(5.1, 0.0, -2.05), Vector3(1.5, 2.2, 1.4))


static func small_default() -> ShopGrid:
	var grid := ShopGrid.new()
	grid.width = ShopState.SMALL_GRID_WIDTH
	grid.height = ShopState.SMALL_GRID_HEIGHT
	grid.tile_size = TILE_SIZE
	grid.entrance_tile = Vector2i(4, 0)
	grid.desk_tile = Vector2i(6, 1)
	grid.queue_tiles = [
		Vector2i(6, 1),
		Vector2i(5, 1),
		Vector2i(5, 2),
	]
	grid.browse_tiles = [
		Vector2i(6, 3),
		Vector2i(1, 3),
		Vector2i(2, 6),
		Vector2i(4, 5),
	]
	grid.desk_aabb = AABB(Vector3(5.1, 0.0, -2.05), Vector3(1.5, 2.2, 1.4))
	for tile: Vector2i in [
		Vector2i(7, 1), Vector2i(8, 1),
		Vector2i(9, 1),
		Vector2i(9, 2),
		Vector2i(7, 3), Vector2i(8, 3),
		Vector2i(7, 4), Vector2i(8, 4),
		Vector2i(1, 4),
		Vector2i(2, 4), Vector2i(3, 4),
		Vector2i(2, 5), Vector2i(3, 5),
		Vector2i(9, 5), Vector2i(9, 6),
		Vector2i(0, 7),
		Vector2i(1, 7), Vector2i(2, 7),
		Vector2i(4, 7),
		Vector2i(5, 7),
	]:
		grid.blocked[tile] = true
	return grid


func is_inside(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < width and tile.y < height


func is_walkable(tile: Vector2i) -> bool:
	return is_inside(tile) and not blocked.has(tile)


func world_to_tile(world: Vector3) -> Vector2i:
	return Vector2i(
		int(floor(world.x / tile_size)),
		int(floor(-world.z / tile_size))
	)


func tile_to_world(tile: Vector2i) -> Vector3:
	return Vector3(
		(float(tile.x) + 0.5) * tile_size,
		0.0,
		-(float(tile.y) + 0.5) * tile_size
	)


func nearest_walkable(tile: Vector2i) -> Vector2i:
	if is_walkable(tile):
		return tile
	var visited: Dictionary = {}
	var queue: Array[Vector2i] = [tile]
	visited[tile] = true
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		for neighbor: Vector2i in neighbors(current):
			if visited.has(neighbor):
				continue
			if is_walkable(neighbor):
				return neighbor
			if is_inside(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	return Vector2i(-1, -1)


func neighbors(tile: Vector2i) -> Array[Vector2i]:
	return [
		tile + Vector2i(1, 0),
		tile + Vector2i(-1, 0),
		tile + Vector2i(0, 1),
		tile + Vector2i(0, -1),
	]


func contains_desk(world: Vector3) -> bool:
	var min_corner := desk_aabb.position
	var max_corner := desk_aabb.position + desk_aabb.size
	return (
		world.x >= min_corner.x
		and world.x <= max_corner.x
		and world.z >= min_corner.z
		and world.z <= max_corner.z
	)
