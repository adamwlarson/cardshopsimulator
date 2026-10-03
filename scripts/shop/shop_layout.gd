class_name ShopLayout
extends RefCounted

const DEFAULT_ENTRANCE := Vector2i(4, 0)
const PLAY_TABLE_ID := &"play_table"
const PLAY_TABLE_SIZE := Vector2i(2, 2)
const PLAY_TABLE_DEFAULT_ORIGIN := Vector2i(2, 4)

var width: int = ShopState.SMALL_GRID_WIDTH
var height: int = ShopState.SMALL_GRID_HEIGHT
var entrance: Vector2i = DEFAULT_ENTRANCE
var fixtures: Array[ShopFixture] = []


func _init() -> void:
	reset_small()


func reset_small() -> void:
	width = ShopState.SMALL_GRID_WIDTH
	height = ShopState.SMALL_GRID_HEIGHT
	entrance = DEFAULT_ENTRANCE
	fixtures.clear()
	_add_architecture(&"alcove_north", Vector2i(8, 0), Vector2i(2, 1))
	_add_architecture(&"alcove_south", Vector2i(8, 2), Vector2i(2, 1))
	var counter := _make_fixture(
		&"counter",
		&"counter",
		"Checkout counter",
		Vector2i(8, 1),
		Vector2i(2, 1)
	)
	counter.is_counter = true
	counter.movable = false
	fixtures.append(counter)
	var display_case := _make_fixture(
		&"display_case",
		&"display_case",
		"High-value display case",
		Vector2i(6, 4),
		Vector2i(2, 1)
	)
	display_case.is_display = true
	display_case.movable = true
	fixtures.append(display_case)
	var binder := _make_fixture(
		&"binder_rack",
		&"binder_rack",
		"Binder rack",
		Vector2i(1, 4),
		Vector2i.ONE
	)
	binder.is_display = true
	binder.movable = true
	fixtures.append(binder)
	var shelf := _make_fixture(
		&"shelf",
		&"shelf",
		"Wall shelf",
		Vector2i(9, 5),
		Vector2i(1, 2)
	)
	shelf.is_display = true
	shelf.movable = true
	fixtures.append(shelf)


func fixture_by_id(fixture_id: StringName) -> ShopFixture:
	for fixture: ShopFixture in fixtures:
		if fixture.id == fixture_id:
			return fixture
	return null


func movable_fixtures() -> Array[ShopFixture]:
	var result: Array[ShopFixture] = []
	for fixture: ShopFixture in fixtures:
		if fixture.movable:
			result.append(fixture)
	return result


func has_play_table() -> bool:
	return play_table() != null


func play_table() -> ShopFixture:
	return fixture_by_id(PLAY_TABLE_ID)


func preview_place_play_table(origin: Vector2i) -> StringName:
	if has_play_table():
		return &"already_placed"
	if not _footprint_in_bounds(origin, PLAY_TABLE_SIZE):
		return &"out_of_bounds"
	var fixture := _make_play_table_fixture(origin)
	fixtures.append(fixture)
	var overlap := _has_overlap()
	var circulation := has_circulation()
	fixtures.pop_back()
	if overlap:
		return &"overlap"
	if not circulation:
		return &"blocked_path"
	return &"ok"


func place_play_table(origin: Vector2i) -> StringName:
	var reason := preview_place_play_table(origin)
	if reason != &"ok" and reason != &"blocked_path":
		return reason
	if has_play_table():
		return &"already_placed"
	fixtures.append(_make_play_table_fixture(origin))
	return reason


func allows_blocked_move(fixture: ShopFixture) -> bool:
	return fixture != null and fixture.kind == PLAY_TABLE_ID


func has_circulation() -> bool:
	return not circulation_path().is_empty()


func circulation_path() -> Array[Vector2i]:
	var blocked := _blocked_cells()
	var display_tiles := _walkable_neighbors(_display_cells(), blocked)
	var counter_tiles := _walkable_neighbors(_counter_cells(), blocked)
	if display_tiles.is_empty() or counter_tiles.is_empty():
		return []
	if not _in_bounds(entrance) or blocked.has(entrance):
		return []
	var to_displays := _bfs(entrance, display_tiles, blocked)
	if to_displays.is_empty():
		return []
	var display_end := to_displays[to_displays.size() - 1]
	var to_counter := _bfs(display_end, counter_tiles, blocked)
	if to_counter.is_empty():
		return []
	var path := to_displays.duplicate()
	for index: int in range(1, to_counter.size()):
		path.append(to_counter[index])
	return path


func preview_move(fixture_id: StringName, new_origin: Vector2i) -> StringName:
	var fixture := fixture_by_id(fixture_id)
	if fixture == null:
		return &"unknown_fixture"
	if not fixture.movable:
		return &"immovable"
	if fixture.origin == new_origin:
		return &"unchanged"
	if not _footprint_in_bounds(new_origin, fixture.size):
		return &"out_of_bounds"
	var saved := fixture.origin
	fixture.origin = new_origin
	var overlap := _has_overlap()
	var circulation := has_circulation()
	fixture.origin = saved
	if overlap:
		return &"overlap"
	if not circulation:
		return &"blocked_path"
	return &"ok"


func apply_move(fixture_id: StringName, new_origin: Vector2i) -> StringName:
	var reason := preview_move(fixture_id, new_origin)
	var fixture := fixture_by_id(fixture_id)
	if reason != &"ok" and not (reason == &"blocked_path" and allows_blocked_move(fixture)):
		return reason
	fixture.origin = new_origin
	return reason


func walkable_tile_count() -> int:
	return maxi(0, width * height - _blocked_cells().size())


func would_circulate_at(new_width: int, new_height: int) -> bool:
	return preview_expand(new_width, new_height) == &"ok"


func preview_expand(new_width: int, new_height: int) -> StringName:
	if new_width < width or new_height < height:
		return &"out_of_bounds"
	var saved_width := width
	var saved_height := height
	width = new_width
	height = new_height
	var circulation := has_circulation()
	width = saved_width
	height = saved_height
	if not circulation:
		return &"blocked_path"
	return &"ok"


func expand(new_width: int, new_height: int) -> StringName:
	var reason := preview_expand(new_width, new_height)
	if reason != &"ok":
		return reason
	width = new_width
	height = new_height
	return &"ok"


func to_save() -> Dictionary:
	var rows: Array[Dictionary] = []
	for fixture: ShopFixture in fixtures:
		rows.append(fixture.to_save())
	return {
		"width": width,
		"height": height,
		"entrance_x": entrance.x,
		"entrance_y": entrance.y,
		"fixtures": rows,
	}


func apply_save(data: Dictionary) -> void:
	width = int(data.get("width", ShopState.SMALL_GRID_WIDTH))
	height = int(data.get("height", ShopState.SMALL_GRID_HEIGHT))
	entrance = Vector2i(
		int(data.get("entrance_x", DEFAULT_ENTRANCE.x)),
		int(data.get("entrance_y", DEFAULT_ENTRANCE.y))
	)
	fixtures.clear()
	var rows: Array = data.get("fixtures", [])
	for row: Variant in rows:
		if row is Dictionary:
			fixtures.append(ShopFixture.from_save(row as Dictionary))


func _add_architecture(
	architecture_id: StringName,
	origin: Vector2i,
	size: Vector2i
) -> void:
	var fixture := _make_fixture(
		architecture_id,
		&"architecture",
		"Architecture",
		origin,
		size
	)
	fixtures.append(fixture)


func _make_fixture(
	fixture_id: StringName,
	kind: StringName,
	display_name: String,
	origin: Vector2i,
	size: Vector2i
) -> ShopFixture:
	return ShopFixture.new(fixture_id, kind, display_name, origin, size)


func _make_play_table_fixture(origin: Vector2i) -> ShopFixture:
	var fixture := _make_fixture(
		PLAY_TABLE_ID,
		PLAY_TABLE_ID,
		"Play table",
		origin,
		PLAY_TABLE_SIZE
	)
	fixture.movable = true
	fixture.is_display = false
	return fixture


func _blocked_cells() -> Dictionary:
	var blocked := {}
	for fixture: ShopFixture in fixtures:
		for cell: Vector2i in fixture.occupied_cells():
			blocked[cell] = true
	return blocked


func _display_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for fixture: ShopFixture in fixtures:
		if fixture.is_display:
			cells.append_array(fixture.occupied_cells())
	return cells


func _counter_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for fixture: ShopFixture in fixtures:
		if fixture.is_counter:
			cells.append_array(fixture.occupied_cells())
	return cells


func _has_overlap() -> bool:
	var seen := {}
	for fixture: ShopFixture in fixtures:
		for cell: Vector2i in fixture.occupied_cells():
			if seen.has(cell):
				return true
			seen[cell] = true
	return false


func _footprint_in_bounds(origin: Vector2i, size: Vector2i) -> bool:
	if origin.x < 0 or origin.y < 0:
		return false
	if origin.x + size.x > width or origin.y + size.y > height:
		return false
	return true


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func _walkable_neighbors(occupied: Array[Vector2i], blocked: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var seen := {}
	for cell: Vector2i in occupied:
		for neighbor: Vector2i in _neighbors(cell):
			if not _in_bounds(neighbor) or blocked.has(neighbor) or seen.has(neighbor):
				continue
			seen[neighbor] = true
			result.append(neighbor)
	return result


func _neighbors(cell: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(cell.x + 1, cell.y),
		Vector2i(cell.x - 1, cell.y),
		Vector2i(cell.x, cell.y + 1),
		Vector2i(cell.x, cell.y - 1),
	]


func _bfs(
	start: Vector2i,
	goals: Array[Vector2i],
	blocked: Dictionary
) -> Array[Vector2i]:
	var goal_set := {}
	for goal: Vector2i in goals:
		goal_set[goal] = true
	if goal_set.has(start):
		return [start]
	var came_from := {}
	var queue: Array[Vector2i] = [start]
	var seen := {start: true}
	var found := Vector2i(-1, -1)
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		for neighbor: Vector2i in _neighbors(current):
			if (
				not _in_bounds(neighbor)
				or blocked.has(neighbor)
				or seen.has(neighbor)
			):
				continue
			seen[neighbor] = true
			came_from[neighbor] = current
			if goal_set.has(neighbor):
				found = neighbor
				queue.clear()
				break
			queue.append(neighbor)
	if found == Vector2i(-1, -1):
		return []
	var path: Array[Vector2i] = [found]
	var walk := found
	while walk != start:
		walk = came_from[walk]
		path.push_front(walk)
	return path
