class_name ShopFloorExtent
extends Node3D

## Code-driven Medium shell stub until Art delivers `prop_shop_shell` Medium.
## Matches Small shell material language (IMPORT_NOTES): gray floor, cream walls,
## wood trim, warm ceiling. Hides the Small GLB on Medium so walls do not clip
## the unlocked tiles. Not a hero mesh.

const TILE_M := ShopGrid.TILE_SIZE
const WALL_HEIGHT_M := 2.80
const FLOOR_THICKNESS := 0.06
const WALL_THICKNESS := 0.12
const TRIM_HEIGHT := 0.10
const CEILING_THICKNESS := 0.06
const FLOOR_COLOR := Color(0.42, 0.43, 0.45, 1.0)
const WALL_COLOR := Color(0.82, 0.78, 0.72, 1.0)
const TRIM_COLOR := Color(0.45, 0.32, 0.22, 1.0)
const CEILING_COLOR := Color(0.92, 0.90, 0.86, 1.0)

var _medium_active: bool = false


func _ready() -> void:
	_bind_bus()
	sync_from_shop()


func is_medium_extension_visible() -> bool:
	return _medium_active and has_node("MediumFloor")


func extra_floor_tile_count() -> int:
	if not _medium_active:
		return 0
	return (
		ShopState.MEDIUM_GRID_WIDTH * ShopState.MEDIUM_GRID_HEIGHT
		- ShopState.SMALL_GRID_WIDTH * ShopState.SMALL_GRID_HEIGHT
	)


func has_fog_veil() -> bool:
	return has_node("MediumVeilX") or has_node("MediumVeilZ")


func sync_from_shop() -> void:
	var shop := _shop()
	var want_medium := shop != null and shop.tier == ShopState.Tier.MEDIUM
	if want_medium == _medium_active and (not want_medium or has_node("MediumFloor")):
		_set_art_shell_visible(not want_medium)
		return
	_clear_extension()
	_medium_active = want_medium
	_set_art_shell_visible(not want_medium)
	if want_medium:
		_build_medium_shell()


func _bind_bus() -> void:
	var bus := _autoload("EventBus")
	if bus == null:
		return
	if not bus.is_connected("shop_layout_changed", _on_shop_layout_changed):
		bus.connect("shop_layout_changed", _on_shop_layout_changed)
	if not bus.is_connected("day_started", _on_day_started):
		bus.connect("day_started", _on_day_started)


func _on_shop_layout_changed() -> void:
	sync_from_shop()


func _on_day_started(_day: int) -> void:
	sync_from_shop()


func _set_art_shell_visible(visible: bool) -> void:
	if get_parent() == null:
		return
	var shell := get_parent().get_node_or_null("Architecture/ShopShell") as Node3D
	if shell != null:
		shell.visible = visible


func _clear_extension() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func _build_medium_shell() -> void:
	var width_m := float(ShopState.MEDIUM_GRID_WIDTH) * TILE_M
	var depth_m := float(ShopState.MEDIUM_GRID_HEIGHT) * TILE_M
	_add_box(
		"MediumFloor",
		Vector3(width_m, FLOOR_THICKNESS, depth_m),
		Vector3(width_m * 0.5, -FLOOR_THICKNESS * 0.5, -depth_m * 0.5),
		FLOOR_COLOR
	)
	_add_box(
		"MediumCeiling",
		Vector3(width_m, CEILING_THICKNESS, depth_m),
		Vector3(width_m * 0.5, WALL_HEIGHT_M + CEILING_THICKNESS * 0.5, -depth_m * 0.5),
		CEILING_COLOR
	)
	_add_box(
		"MediumWallSouth",
		Vector3(width_m + WALL_THICKNESS, WALL_HEIGHT_M, WALL_THICKNESS),
		Vector3(width_m * 0.5, WALL_HEIGHT_M * 0.5, WALL_THICKNESS * 0.5),
		WALL_COLOR
	)
	_add_box(
		"MediumWallNorth",
		Vector3(width_m + WALL_THICKNESS, WALL_HEIGHT_M, WALL_THICKNESS),
		Vector3(width_m * 0.5, WALL_HEIGHT_M * 0.5, -(depth_m + WALL_THICKNESS * 0.5)),
		WALL_COLOR
	)
	_add_box(
		"MediumWallWest",
		Vector3(WALL_THICKNESS, WALL_HEIGHT_M, depth_m),
		Vector3(-WALL_THICKNESS * 0.5, WALL_HEIGHT_M * 0.5, -depth_m * 0.5),
		WALL_COLOR
	)
	_add_box(
		"MediumWallEast",
		Vector3(WALL_THICKNESS, WALL_HEIGHT_M, depth_m),
		Vector3(width_m + WALL_THICKNESS * 0.5, WALL_HEIGHT_M * 0.5, -depth_m * 0.5),
		WALL_COLOR
	)
	_add_box(
		"MediumTrimSouth",
		Vector3(width_m + WALL_THICKNESS, TRIM_HEIGHT, WALL_THICKNESS + 0.02),
		Vector3(width_m * 0.5, TRIM_HEIGHT * 0.5, WALL_THICKNESS * 0.5),
		TRIM_COLOR
	)
	_add_box(
		"MediumTrimNorth",
		Vector3(width_m + WALL_THICKNESS, TRIM_HEIGHT, WALL_THICKNESS + 0.02),
		Vector3(width_m * 0.5, TRIM_HEIGHT * 0.5, -(depth_m + WALL_THICKNESS * 0.5)),
		TRIM_COLOR
	)
	_add_box(
		"MediumTrimWest",
		Vector3(WALL_THICKNESS + 0.02, TRIM_HEIGHT, depth_m),
		Vector3(-WALL_THICKNESS * 0.5, TRIM_HEIGHT * 0.5, -depth_m * 0.5),
		TRIM_COLOR
	)
	_add_box(
		"MediumTrimEast",
		Vector3(WALL_THICKNESS + 0.02, TRIM_HEIGHT, depth_m),
		Vector3(width_m + WALL_THICKNESS * 0.5, TRIM_HEIGHT * 0.5, -depth_m * 0.5),
		TRIM_COLOR
	)


func _add_box(node_name: String, size: Vector3, origin: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = origin
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62
	instance.material_override = material
	add_child(instance)


func _shop() -> ShopState:
	var gs := _autoload("GameState")
	if gs == null:
		return null
	return gs.get("shop") as ShopState


func _autoload(node_name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(node_name)
