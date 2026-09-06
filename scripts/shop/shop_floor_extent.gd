class_name ShopFloorExtent
extends Node3D

## Toggles Art shop shells after Sign. Small stays `prop_shop_shell_01`;
## Medium instances `prop_shop_shell_medium_01` at SW origin, scale 1 (1u=1m).
## Walkable grid SoT remains 14×10 @ 0.9 m. No code-driven MediumFloor stub.
## Fog-as-Medium stays nacked.
## Medium overhead extras (same `prop_light_overhead_01`) show at Medium+Large.
## Large Art shell may lag — Eng ships a scaffold interim floor (not a fog veil).

const MEDIUM_SHELL_SCENE := (
	"res://assets/props/shop/fixtures/prop_shop_shell_medium_01/prop_shop_shell_medium_01.glb"
)
const SMALL_SHELL_PATH := "Architecture/ShopShell"
const MEDIUM_SHELL_PATH := "Architecture/ShopShellMedium"
const OVERHEAD_LIGHTS_PATH := "Fixtures/OverheadLights"
const SMALL_OVERHEAD_MESH_NAMES := [
	"FrontLeft",
	"FrontRight",
	"BackLeft",
	"BackRight",
	"BackLeftAisle",
]
const MEDIUM_OVERHEAD_MESH_NAMES := [
	"MidCenter",
	"FarFront",
	"FarBack",
	"DeepLeft",
	"DeepCenter",
	"DeepRight",
]
const STUB_NODE_NAMES := [
	"MediumFloor",
	"MediumCeiling",
	"MediumWallSouth",
	"MediumWallNorth",
	"MediumWallWest",
	"MediumWallEast",
	"MediumTrimSouth",
	"MediumTrimNorth",
	"MediumTrimWest",
	"MediumTrimEast",
]
const LARGE_SCAFFOLD_NAMES := [
	"LargeFloor",
	"LargeWallEast",
	"LargeWallNorth",
]
const LARGE_SCAFFOLD_COLOR := Color(0.42, 0.40, 0.36, 1.0)
const LARGE_WALL_COLOR := Color(0.34, 0.32, 0.29, 1.0)

var _medium_active: bool = false
var _large_active: bool = false


func _ready() -> void:
	_bind_bus()
	sync_from_shop()


func is_medium_extension_visible() -> bool:
	var shell := _medium_shell()
	return _medium_active and shell != null and shell.visible


func extra_floor_tile_count() -> int:
	if _large_active:
		return (
			ShopState.LARGE_GRID_WIDTH * ShopState.LARGE_GRID_HEIGHT
			- ShopState.SMALL_GRID_WIDTH * ShopState.SMALL_GRID_HEIGHT
		)
	if not _medium_active:
		return 0
	return (
		ShopState.MEDIUM_GRID_WIDTH * ShopState.MEDIUM_GRID_HEIGHT
		- ShopState.SMALL_GRID_WIDTH * ShopState.SMALL_GRID_HEIGHT
	)


func extra_large_tile_count() -> int:
	if not _large_active:
		return 0
	return (
		ShopState.LARGE_GRID_WIDTH * ShopState.LARGE_GRID_HEIGHT
		- ShopState.MEDIUM_GRID_WIDTH * ShopState.MEDIUM_GRID_HEIGHT
	)


func is_large_scaffold_visible() -> bool:
	if not _large_active:
		return false
	var floor_mesh := get_node_or_null("LargeFloor") as Node3D
	return floor_mesh != null and floor_mesh.visible


func has_large_scaffold() -> bool:
	for node_name: String in LARGE_SCAFFOLD_NAMES:
		if has_node(node_name):
			return true
	return false


func has_fog_veil() -> bool:
	return has_node("MediumVeilX") or has_node("MediumVeilZ")


func has_code_driven_stub() -> bool:
	for node_name: String in STUB_NODE_NAMES:
		if has_node(node_name):
			return true
	return false


func is_medium_overhead_visible() -> bool:
	if not _medium_active:
		return false
	var root := _overhead_lights()
	if root == null:
		return false
	for mesh_name: String in MEDIUM_OVERHEAD_MESH_NAMES:
		var mesh := root.get_node_or_null(mesh_name) as Node3D
		var fill := root.get_node_or_null("%sFill" % mesh_name) as Node3D
		if mesh == null or fill == null or not mesh.visible or not fill.visible:
			return false
	return true


func visible_overhead_mesh_count() -> int:
	return _count_visible_overheads(SMALL_OVERHEAD_MESH_NAMES) + _count_visible_overheads(
		MEDIUM_OVERHEAD_MESH_NAMES
	)


func visible_overhead_fill_count() -> int:
	var root := _overhead_lights()
	if root == null:
		return 0
	var count := 0
	for mesh_name: String in SMALL_OVERHEAD_MESH_NAMES:
		var fill := root.get_node_or_null("%sFill" % mesh_name) as Node3D
		if fill != null and fill.visible:
			count += 1
	for mesh_name: String in MEDIUM_OVERHEAD_MESH_NAMES:
		var fill := root.get_node_or_null("%sFill" % mesh_name) as Node3D
		if fill != null and fill.visible:
			count += 1
	return count


func sync_from_shop() -> void:
	var shop := _shop()
	_medium_active = (
		shop != null
		and shop.tier in [ShopState.Tier.MEDIUM, ShopState.Tier.LARGE]
	)
	_large_active = shop != null and shop.tier == ShopState.Tier.LARGE
	_clear_extension()
	_ensure_medium_shell()
	_ensure_large_scaffold()
	_apply_shell_visibility()
	_apply_medium_overhead_visibility()


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


func _apply_shell_visibility() -> void:
	var small := _small_shell()
	if small != null:
		small.visible = not _medium_active
	var medium := _medium_shell()
	if medium != null:
		medium.visible = _medium_active
		if _medium_active:
			medium.position = Vector3.ZERO
			medium.scale = Vector3.ONE


func _apply_medium_overhead_visibility() -> void:
	var root := _overhead_lights()
	if root == null:
		return
	for mesh_name: String in MEDIUM_OVERHEAD_MESH_NAMES:
		var mesh := root.get_node_or_null(mesh_name) as Node3D
		if mesh != null:
			mesh.visible = _medium_active
			mesh.scale = Vector3.ONE
		var fill := root.get_node_or_null("%sFill" % mesh_name) as Node3D
		if fill != null:
			fill.visible = _medium_active


func _count_visible_overheads(mesh_names: Array) -> int:
	var root := _overhead_lights()
	if root == null:
		return 0
	var count := 0
	for mesh_name: Variant in mesh_names:
		var mesh := root.get_node_or_null(String(mesh_name)) as Node3D
		if mesh != null and mesh.visible:
			count += 1
	return count


func _ensure_medium_shell() -> void:
	if _medium_shell() != null:
		return
	if get_parent() == null:
		return
	var architecture := get_parent().get_node_or_null("Architecture") as Node3D
	if architecture == null:
		return
	var packed := load(MEDIUM_SHELL_SCENE) as PackedScene
	if packed == null:
		return
	var shell := packed.instantiate() as Node3D
	if shell == null:
		return
	shell.name = "ShopShellMedium"
	shell.position = Vector3.ZERO
	shell.scale = Vector3.ONE
	shell.visible = false
	architecture.add_child(shell)


func _ensure_large_scaffold() -> void:
	if not _large_active:
		return
	var tile := ShopGrid.TILE_SIZE
	var large_w := float(ShopState.LARGE_GRID_WIDTH) * tile
	var large_h := float(ShopState.LARGE_GRID_HEIGHT) * tile
	_add_scaffold_box(
		"LargeFloor",
		Vector3(large_w, 0.04, large_h),
		Vector3(large_w * 0.5, -0.02, -large_h * 0.5),
		LARGE_SCAFFOLD_COLOR
	)
	_add_scaffold_box(
		"LargeWallEast",
		Vector3(0.12, 2.4, large_h),
		Vector3(large_w + 0.06, 1.2, -large_h * 0.5),
		LARGE_WALL_COLOR
	)
	_add_scaffold_box(
		"LargeWallNorth",
		Vector3(large_w, 2.4, 0.12),
		Vector3(large_w * 0.5, 1.2, -(large_h + 0.06)),
		LARGE_WALL_COLOR
	)


func _add_scaffold_box(
	node_name: String,
	size: Vector3,
	position: Vector3,
	color: Color
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	box.material = mat
	mesh_instance.mesh = box
	mesh_instance.position = position
	add_child(mesh_instance)


func _clear_extension() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func _small_shell() -> Node3D:
	if get_parent() == null:
		return null
	return get_parent().get_node_or_null(SMALL_SHELL_PATH) as Node3D


func _medium_shell() -> Node3D:
	if get_parent() == null:
		return null
	return get_parent().get_node_or_null(MEDIUM_SHELL_PATH) as Node3D


func _overhead_lights() -> Node3D:
	if get_parent() == null:
		return null
	return get_parent().get_node_or_null(OVERHEAD_LIGHTS_PATH) as Node3D


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
