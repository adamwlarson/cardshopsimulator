class_name ShopFixture
extends RefCounted

var id: StringName
var kind: StringName
var display_name: String
var origin: Vector2i
var size: Vector2i = Vector2i.ONE
var movable: bool = false
var is_display: bool = false
var is_counter: bool = false


func _init(
	fixture_id: StringName = &"",
	fixture_kind: StringName = &"",
	fixture_name: String = "",
	fixture_origin: Vector2i = Vector2i.ZERO,
	fixture_size: Vector2i = Vector2i.ONE
) -> void:
	id = fixture_id
	kind = fixture_kind
	display_name = fixture_name
	origin = fixture_origin
	size = fixture_size


func occupies(cell: Vector2i) -> bool:
	return (
		cell.x >= origin.x
		and cell.y >= origin.y
		and cell.x < origin.x + size.x
		and cell.y < origin.y + size.y
	)


func occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(origin.x, origin.x + size.x):
		for y: int in range(origin.y, origin.y + size.y):
			cells.append(Vector2i(x, y))
	return cells


func duplicate_fixture() -> ShopFixture:
	var copy := ShopFixture.new(id, kind, display_name, origin, size)
	copy.movable = movable
	copy.is_display = is_display
	copy.is_counter = is_counter
	return copy
