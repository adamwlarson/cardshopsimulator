class_name PlayTablePresenter
extends Node3D

## AB1: show the authored PlayTable prop when the 2×2 fixture is placed.
## No new mesh — reuse B09 `prop_play_table_01` plus a primitive collider.

const TABLE_PATH := "Fixtures/PlayTable"
const COLLIDER_NAME := "PlayTableCollider"
const TILE_SIZE := ShopGrid.TILE_SIZE
const TABLE_HEIGHT := 0.761


func _ready() -> void:
	_bind_bus()
	sync_from_shop()


func sync_from_shop() -> void:
	var table := table_node()
	if table == null:
		return
	var fixture := _placed_fixture()
	if fixture == null:
		table.visible = false
		_ensure_collider(table, false)
		return
	table.visible = true
	table.position = _world_center(fixture)
	table.rotation_degrees = Vector3.ZERO
	table.scale = Vector3.ONE
	_ensure_collider(table, true)


func table_node() -> Node3D:
	if get_parent() == null:
		return null
	return get_parent().get_node_or_null(TABLE_PATH) as Node3D


func table_visible() -> bool:
	var table := table_node()
	return table != null and table.visible


func _placed_fixture() -> ShopFixture:
	var shop := _shop()
	if shop == null:
		return null
	return shop.layout.play_table()


func _world_center(fixture: ShopFixture) -> Vector3:
	var center := Vector2(
		float(fixture.origin.x) + float(fixture.size.x) * 0.5,
		float(fixture.origin.y) + float(fixture.size.y) * 0.5
	)
	return Vector3(center.x * TILE_SIZE, 0.0, -center.y * TILE_SIZE)


func _ensure_collider(table: Node3D, enabled: bool) -> void:
	var body := table.get_node_or_null(COLLIDER_NAME) as StaticBody3D
	if body == null:
		body = StaticBody3D.new()
		body.name = COLLIDER_NAME
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(
			TILE_SIZE * 2.0,
			TABLE_HEIGHT,
			TILE_SIZE * 2.0
		)
		shape.shape = box
		shape.position = Vector3(0.0, TABLE_HEIGHT * 0.5, 0.0)
		body.add_child(shape)
		table.add_child(body)
	body.visible = enabled
	body.process_mode = (
		Node.PROCESS_MODE_INHERIT if enabled else Node.PROCESS_MODE_DISABLED
	)


func _bind_bus() -> void:
	_connect_signal("shop_layout_changed", _on_shop_layout_changed)
	_connect_signal("day_started", _on_day_started)


func _on_shop_layout_changed() -> void:
	sync_from_shop()


func _on_day_started(_day: int) -> void:
	sync_from_shop()


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
