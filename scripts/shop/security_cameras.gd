class_name SecurityCameras
extends Node3D

## Thin shop-floor visual for V1 Camera unlock.
## Instances Art `prop_security_camera_01` (MOUNT pivot, hang −Y, look +Z)
## at SoT Medium ceiling spots. Large adds the optional deep-aisle copy.
## Show when `ShopState.has_cameras()`; hide otherwise. No economy verbs.

const CAMERA_SCENE := (
	"res://assets/props/shop/fixtures/prop_security_camera_01/prop_security_camera_01.glb"
)
const ENTRANCE_NAME := "SecurityCamera"
const AISLE_NAME := "SecurityCameraAisle"
const LARGE_NAME := "SecurityCameraLarge"
## Art SoT Medium ceiling — yaw 180° so authored +Z looks −Z into the shop.
const ENTRANCE_POSITION := Vector3(6.30, 2.80, -1.80)
const AISLE_POSITION := Vector3(4.50, 2.80, -4.20)
const LARGE_POSITION := Vector3(10.40, 2.80, -8.40)
const CEILING_ROTATION_DEGREES := Vector3(0.0, 180.0, 0.0)
## Art SoT wall recipe: on a wall facing +Z into the room, Y=180° then X=−90°.
const WALL_ROTATION_DEGREES := Vector3(-90.0, 180.0, 0.0)
const WALL_EXAMPLE_POSITION := Vector3(6.30, 2.40, -8.95)


func _ready() -> void:
	_bind_bus()
	sync_from_shop()


func sync_from_shop() -> void:
	_ensure_camera(ENTRANCE_NAME, ENTRANCE_POSITION, CEILING_ROTATION_DEGREES)
	_ensure_camera(AISLE_NAME, AISLE_POSITION, CEILING_ROTATION_DEGREES)
	_ensure_camera(LARGE_NAME, LARGE_POSITION, CEILING_ROTATION_DEGREES)
	_apply_visibility()


func owned_cameras_visible() -> bool:
	return (
		_cameras_owned()
		and _is_visible(ENTRANCE_NAME)
		and _is_visible(AISLE_NAME)
	)


func large_camera_visible() -> bool:
	return _cameras_owned() and _is_large() and _is_visible(LARGE_NAME)


func visible_camera_count() -> int:
	var count := 0
	for node_name: String in [ENTRANCE_NAME, AISLE_NAME, LARGE_NAME]:
		if _is_visible(node_name):
			count += 1
	return count


func camera_node(node_name: String) -> Node3D:
	return get_node_or_null(node_name) as Node3D


func _bind_bus() -> void:
	_connect_signal("cameras_changed", _on_cameras_changed)
	_connect_signal("shop_layout_changed", _on_shop_layout_changed)
	_connect_signal("day_started", _on_day_started)


func _on_cameras_changed() -> void:
	sync_from_shop()


func _on_shop_layout_changed() -> void:
	sync_from_shop()


func _on_day_started(_day: int) -> void:
	sync_from_shop()


func _apply_visibility() -> void:
	var owned := _cameras_owned()
	_show_camera(ENTRANCE_NAME, ENTRANCE_POSITION, CEILING_ROTATION_DEGREES, owned)
	_show_camera(AISLE_NAME, AISLE_POSITION, CEILING_ROTATION_DEGREES, owned)
	_show_camera(LARGE_NAME, LARGE_POSITION, CEILING_ROTATION_DEGREES, owned and _is_large())


func _show_camera(
	node_name: String,
	position_m: Vector3,
	rotation_degrees: Vector3,
	should_show: bool
) -> void:
	var node := camera_node(node_name)
	if node == null:
		return
	node.visible = should_show
	node.position = position_m
	node.rotation_degrees = rotation_degrees
	node.scale = Vector3.ONE


func _ensure_camera(
	node_name: String,
	position_m: Vector3,
	rotation_degrees: Vector3
) -> void:
	if camera_node(node_name) != null:
		return
	if not ResourceLoader.exists(CAMERA_SCENE):
		return
	var packed := load(CAMERA_SCENE) as PackedScene
	if packed == null:
		return
	var node := packed.instantiate() as Node3D
	if node == null:
		return
	node.name = node_name
	node.visible = false
	node.position = position_m
	node.rotation_degrees = rotation_degrees
	node.scale = Vector3.ONE
	add_child(node)


func _is_visible(node_name: String) -> bool:
	var node := camera_node(node_name)
	return node != null and node.visible


func _cameras_owned() -> bool:
	var shop := _shop()
	return shop != null and shop.has_cameras()


func _is_large() -> bool:
	var shop := _shop()
	return shop != null and shop.tier == ShopState.Tier.LARGE


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


func _connect_signal(signal_name: String, callback: Callable) -> void:
	var bus := _autoload("EventBus")
	if bus == null:
		return
	if not bus.is_connected(signal_name, callback):
		bus.connect(signal_name, callback)
