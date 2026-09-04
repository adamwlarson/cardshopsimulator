class_name ShopFloorExtent
extends Node3D

## Code-driven Medium floor + fog until Art delivers a Medium shell.
## Does not replace or invent hero meshes; Small GLB stays in place.

const SMALL_SIZE_M := Vector2(
	float(ShopState.SMALL_GRID_WIDTH) * ShopGrid.TILE_SIZE,
	float(ShopState.SMALL_GRID_HEIGHT) * ShopGrid.TILE_SIZE
)
const MEDIUM_SIZE_M := Vector2(
	float(ShopState.MEDIUM_GRID_WIDTH) * ShopGrid.TILE_SIZE,
	float(ShopState.MEDIUM_GRID_HEIGHT) * ShopGrid.TILE_SIZE
)
const FLOOR_THICKNESS := 0.04
const VEIL_HEIGHT := 2.8
const VEIL_THICKNESS := 0.12

var _medium_active: bool = false


func _ready() -> void:
	_bind_bus()
	sync_from_shop()


func is_medium_extension_visible() -> bool:
	return _medium_active and has_node("MediumFloorX")


func extra_floor_tile_count() -> int:
	if not _medium_active:
		return 0
	return (
		ShopState.MEDIUM_GRID_WIDTH * ShopState.MEDIUM_GRID_HEIGHT
		- ShopState.SMALL_GRID_WIDTH * ShopState.SMALL_GRID_HEIGHT
	)


func sync_from_shop() -> void:
	var shop := _shop()
	var want_medium := shop != null and shop.tier == ShopState.Tier.MEDIUM
	if want_medium == _medium_active and (not want_medium or has_node("MediumFloorX")):
		_sync_camera()
		return
	_clear_extension()
	_medium_active = want_medium
	if want_medium:
		_build_medium_extension()
	_sync_camera()


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


func _sync_camera() -> void:
	if get_parent() == null:
		return
	var camera := get_parent().get_node_or_null("Camera") as ShopCamera
	if camera != null:
		camera.set_medium_extent(_medium_active)


func _clear_extension() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func _build_medium_extension() -> void:
	var extra_width := MEDIUM_SIZE_M.x - SMALL_SIZE_M.x
	var extra_depth := MEDIUM_SIZE_M.y - SMALL_SIZE_M.y
	_add_box(
		"MediumFloorX",
		Vector3(extra_width, FLOOR_THICKNESS, MEDIUM_SIZE_M.y),
		Vector3(
			SMALL_SIZE_M.x + extra_width * 0.5,
			-FLOOR_THICKNESS * 0.5,
			-MEDIUM_SIZE_M.y * 0.5
		),
		Color(0.16, 0.18, 0.20, 1.0),
		false
	)
	_add_box(
		"MediumFloorZ",
		Vector3(SMALL_SIZE_M.x, FLOOR_THICKNESS, extra_depth),
		Vector3(
			SMALL_SIZE_M.x * 0.5,
			-FLOOR_THICKNESS * 0.5,
			-(SMALL_SIZE_M.y + extra_depth * 0.5)
		),
		Color(0.16, 0.18, 0.20, 1.0),
		false
	)
	_add_box(
		"MediumVeilX",
		Vector3(VEIL_THICKNESS, VEIL_HEIGHT, MEDIUM_SIZE_M.y),
		Vector3(SMALL_SIZE_M.x, VEIL_HEIGHT * 0.5, -MEDIUM_SIZE_M.y * 0.5),
		Color(0.55, 0.62, 0.70, 0.32),
		true
	)
	_add_box(
		"MediumVeilZ",
		Vector3(MEDIUM_SIZE_M.x, VEIL_HEIGHT, VEIL_THICKNESS),
		Vector3(MEDIUM_SIZE_M.x * 0.5, VEIL_HEIGHT * 0.5, -SMALL_SIZE_M.y),
		Color(0.55, 0.62, 0.70, 0.32),
		true
	)


func _add_box(
	node_name: String,
	size: Vector3,
	origin: Vector3,
	color: Color,
	fog: bool
) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = origin
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if fog:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
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
