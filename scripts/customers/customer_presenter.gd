class_name CustomerPresenter
extends Node3D

enum FloorState {
	SPAWN,
	BROWSE,
	APPROACH,
	RESOLVE,
	EXIT,
}

const BROWSE_DWELL_MIN := 2.0
const BROWSE_DWELL_MAX := 6.0
const BROWSE_PATIENCE_SCALE := 0.25
const BROWSE_COUNT_MIN := 1
const BROWSE_COUNT_MAX := 3

var instant_travel: bool = false
var dwell_override: float = -1.0

var _grid: ShopGrid = ShopGrid.small_default()
var _npcs: Dictionary = {}
var _dwell_left: Dictionary = {}
var _browse_queues: Dictionary = {}
var _desk_ready: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _floor_root: Node3D
var _npc_parent: Node3D
var _browse_points: Array[Vector3] = []
var _queue_points: Array[Vector3] = []
var _entrance: Vector3 = Vector3(4.05, 0.0, -0.45)


func _ready() -> void:
	_rng.randomize()
	_bind_shop_markers()
	_sync_floor_grid()
	if _browse_points.is_empty():
		for tile: Vector2i in _grid.browse_tiles:
			_browse_points.append(_grid.tile_to_world(tile))
	if _queue_points.is_empty():
		for tile: Vector2i in _grid.queue_tiles:
			_queue_points.append(_grid.tile_to_world(tile))
	if _floor_root == null or _floor_root.get_node_or_null("Entrance") == null:
		_entrance = _grid.tile_to_world(_grid.entrance_tile)
	_connect_bus("customer_arrived", _on_customer_arrived)
	_connect_bus("customer_resolved", _on_customer_resolved)
	_connect_bus("customer_head_changed", _on_customer_head_changed)
	_connect_bus("day_phase_changed", _on_phase_changed)
	_connect_bus("shop_layout_changed", _on_shop_layout_changed)


func _bind_shop_markers() -> void:
	var systems := get_parent()
	if systems == null:
		return
	var shop := systems.get_parent()
	if shop == null:
		return
	_floor_root = shop.get_node_or_null("CustomerFloor") as Node3D
	if _floor_root == null:
		return
	_npc_parent = _floor_root.get_node_or_null("Npcs") as Node3D
	if _npc_parent == null:
		_npc_parent = _floor_root
	var entrance_marker := _floor_root.get_node_or_null("Entrance") as Node3D
	if entrance_marker != null:
		_entrance = entrance_marker.position
	var browse_root := _floor_root.get_node_or_null("BrowsePoints")
	if browse_root != null:
		_browse_points.clear()
		for child: Node in browse_root.get_children():
			var marker := child as Node3D
			if marker != null:
				_browse_points.append(marker.position)
	var queue_root := _floor_root.get_node_or_null("QueueSlots")
	if queue_root != null:
		_queue_points.clear()
		for child: Node in queue_root.get_children():
			var marker := child as Node3D
			if marker != null:
				_queue_points.append(marker.position)
	var volume := _floor_root.get_node_or_null("DeskVolume") as Node3D
	if volume != null:
		var shape := volume.get_node_or_null("CollisionShape3D") as CollisionShape3D
		if shape != null and shape.shape is BoxShape3D:
			var box := shape.shape as BoxShape3D
			var center := volume.position + shape.position
			_grid.desk_aabb = AABB(center - box.size * 0.5, box.size)


func _process(delta: float) -> void:
	if not _is_floor_phase() and not instant_travel:
		return
	for npc: CustomerNpc in _npc_list():
		npc.tick_move(delta)
		_tick_state(npc, delta)


func spawn_for(customer: CustomerProfile) -> CustomerNpc:
	if customer == null:
		return null
	var existing := get_npc(customer)
	if existing != null:
		return existing
	var npc := CustomerNpc.new()
	npc.configure(customer)
	npc.set_floor_state(FloorState.SPAWN)
	npc.set_intent(CustomerIntentIcon.Intent.BROWSE)
	_apply_patience_scale(customer, BROWSE_PATIENCE_SCALE)
	var parent: Node = _npc_parent if _npc_parent != null else self
	parent.add_child(npc)
	npc.position = _entrance
	_npcs[customer] = npc
	_desk_ready[customer] = false
	_emit_bus("customer_floor_state_changed", [customer, &"spawn"])
	_emit_bus("customer_intent_changed", [customer, &"browse"])
	return npc


func get_npc(customer: CustomerProfile) -> CustomerNpc:
	return _npcs.get(customer, null) as CustomerNpc


func visible_npc_count() -> int:
	var count := 0
	for npc: CustomerNpc in _npc_list():
		if (
			npc.visible
			and npc.floor_state != FloorState.EXIT
		):
			count += 1
	return count


func is_desk_ready(customer: CustomerProfile) -> bool:
	return bool(_desk_ready.get(customer, false))


func path_between(from: Vector3, to: Vector3) -> Array[Vector3]:
	return ShopPathfinder.world_path(_grid, from, to)


func simulate(seconds: float, step: float = 0.1) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		_process(step)
		elapsed += step


func advance_until(
	customer: CustomerProfile,
	state: int,
	max_seconds: float = 30.0
) -> bool:
	var elapsed := 0.0
	while elapsed <= max_seconds:
		var npc := get_npc(customer)
		if npc != null and npc.floor_state == state:
			return true
		_process(0.1)
		elapsed += 0.1
	return false


func _on_customer_arrived(customer: CustomerProfile) -> void:
	if customer == null:
		return
	if not _is_floor_phase() and not instant_travel:
		return
	spawn_for(customer)


func _on_customer_resolved(
	customer: CustomerProfile,
	_outcome: StringName
) -> void:
	var npc := get_npc(customer)
	if npc == null:
		return
	_set_desk_ready(customer, false)
	_enter_exit(npc)


func _on_customer_head_changed(customer: CustomerProfile) -> void:
	_refresh_queue_slots(customer)


func _on_phase_changed(phase: int) -> void:
	if phase == DayPhasePolicy.FLOOR:
		return
	for npc: CustomerNpc in _npc_list():
		_enter_exit(npc)


func _on_shop_layout_changed() -> void:
	_sync_floor_grid()


func _sync_floor_grid() -> void:
	var gs := _autoload("GameState")
	if gs == null:
		return
	var shop := gs.get("shop") as ShopState
	if shop == null or shop.floor_grid == null:
		return
	_grid = shop.floor_grid


func _begin_browse(npc: CustomerNpc) -> void:
	var stops := _pick_browse_stops()
	_browse_queues[npc.customer] = stops
	if stops.is_empty():
		_enter_approach(npc)
		return
	_set_state(npc, FloorState.BROWSE)
	_walk_to(npc, stops[0])


func _tick_state(npc: CustomerNpc, delta: float) -> void:
	match npc.floor_state:
		FloorState.SPAWN:
			_begin_browse(npc)
		FloorState.BROWSE:
			if npc.is_moving():
				return
			_tick_browse_dwell(npc, delta)
		FloorState.APPROACH:
			if npc.is_moving():
				return
			_try_enter_resolve(npc)
		FloorState.RESOLVE:
			_try_enter_resolve(npc)
		FloorState.EXIT:
			if npc.is_moving():
				return
			_despawn(npc)


func _tick_browse_dwell(npc: CustomerNpc, delta: float) -> void:
	var remaining := float(_dwell_left.get(npc.customer, 0.0))
	if remaining <= 0.0:
		remaining = _next_dwell()
		_dwell_left[npc.customer] = remaining
	remaining -= delta
	_dwell_left[npc.customer] = remaining
	if remaining > 0.0:
		return
	var stops: Array = _browse_queues.get(npc.customer, [])
	if stops is Array and not stops.is_empty():
		stops.pop_front()
		_browse_queues[npc.customer] = stops
	if stops is Array and not stops.is_empty():
		_walk_to(npc, stops[0] as Vector3)
		_dwell_left[npc.customer] = 0.0
		return
	_enter_approach(npc)


func _enter_approach(npc: CustomerNpc) -> void:
	_apply_patience_scale(npc.customer, 1.0)
	_flip_intent_once(npc)
	_set_state(npc, FloorState.APPROACH)
	_walk_to(npc, _slot_for(npc.customer))


func _try_enter_resolve(npc: CustomerNpc) -> void:
	if npc.customer == null:
		return
	var at_desk := _grid.contains_desk(_npc_point(npc))
	var is_head := _is_queue_head(npc.customer)
	npc.set_highlighted(is_head)
	if at_desk and is_head:
		if npc.floor_state != FloorState.RESOLVE:
			_set_state(npc, FloorState.RESOLVE)
		_set_desk_ready(npc.customer, true)
		return
	if npc.floor_state == FloorState.RESOLVE and not at_desk:
		_set_state(npc, FloorState.APPROACH)
	_set_desk_ready(npc.customer, false)
	if not npc.is_moving():
		_walk_to(npc, _slot_for(npc.customer))


func _enter_exit(npc: CustomerNpc) -> void:
	_apply_patience_scale(npc.customer, 1.0)
	_set_desk_ready(npc.customer, false)
	_set_state(npc, FloorState.EXIT)
	_walk_to(npc, _entrance)


func _walk_to(npc: CustomerNpc, destination: Vector3) -> void:
	var points := path_between(_npc_point(npc), destination)
	if points.is_empty():
		points = [destination]
	else:
		points[points.size() - 1] = destination
	npc.follow_path(points)
	if instant_travel:
		npc.snap_to_path_end()


func _pick_browse_stops() -> Array[Vector3]:
	var pool := _browse_points.duplicate()
	if pool.is_empty():
		return []
	pool.shuffle()
	var count := mini(
		pool.size(),
		_rng.randi_range(BROWSE_COUNT_MIN, BROWSE_COUNT_MAX)
	)
	var stops: Array[Vector3] = []
	for index: int in count:
		stops.append(pool[index])
	return stops


func _next_dwell() -> float:
	if dwell_override >= 0.0:
		return dwell_override
	if instant_travel:
		return 0.0
	return _rng.randf_range(BROWSE_DWELL_MIN, BROWSE_DWELL_MAX)


func _flip_intent_once(npc: CustomerNpc) -> void:
	if npc.icon != null and npc.icon.intent != CustomerIntentIcon.Intent.BROWSE:
		return
	var next := CustomerIntentIcon.Intent.BUY
	if (
		npc.customer != null
		and npc.customer.trade_intent
		== CustomerProfile.TradeIntent.SELLING_TO_SHOP
	):
		next = CustomerIntentIcon.Intent.SELL
	npc.set_intent(next)
	if npc.icon != null:
		_emit_bus("customer_intent_changed", [npc.customer, npc.icon.intent_name()])


func _slot_for(customer: CustomerProfile) -> Vector3:
	if _queue_points.is_empty():
		return _grid.tile_to_world(_grid.desk_tile)
	var index := _queue_index(customer)
	return _queue_points[mini(index, _queue_points.size() - 1)]


func _queue_index(customer: CustomerProfile) -> int:
	var ordered := _queued_customers()
	var index := ordered.find(customer)
	return maxi(index, 0)


func _queued_customers() -> Array[CustomerProfile]:
	var spawner := _find_spawner()
	if spawner != null:
		var queue: CustomerQueue = spawner.call("get_queue")
		if queue != null:
			return queue.all_customers()
	var ordered: Array[CustomerProfile] = []
	for npc: CustomerNpc in _npc_list():
		if (
			npc.customer != null
			and npc.floor_state != FloorState.EXIT
			and npc.customer.state != CustomerProfile.State.LEFT
			and npc.customer.state != CustomerProfile.State.DONE
		):
			ordered.append(npc.customer)
	return ordered


func _is_queue_head(customer: CustomerProfile) -> bool:
	var spawner := _find_spawner()
	if spawner != null:
		var queue: CustomerQueue = spawner.call("get_queue")
		if queue != null:
			var head := queue.queue_head()
			if head != null:
				return head == customer
	var ordered := _queued_customers()
	return not ordered.is_empty() and ordered[0] == customer


func _refresh_queue_slots(head: CustomerProfile) -> void:
	for npc: CustomerNpc in _npc_list():
		if npc.floor_state in [FloorState.APPROACH, FloorState.RESOLVE]:
			if npc.is_moving():
				continue
			_walk_to(npc, _slot_for(npc.customer))
			if head != null and npc.customer == head:
				_try_enter_resolve(npc)


func _set_state(npc: CustomerNpc, next: int) -> void:
	if npc.floor_state == next:
		return
	npc.set_floor_state(next)
	_emit_bus(
		"customer_floor_state_changed",
		[npc.customer, StringName(FloorState.keys()[next].to_lower())]
	)


func _set_desk_ready(customer: CustomerProfile, ready: bool) -> void:
	var previous := bool(_desk_ready.get(customer, false))
	_desk_ready[customer] = ready
	if previous == ready:
		return
	_emit_bus("customer_desk_ready_changed", [customer, ready])


func _apply_patience_scale(customer: CustomerProfile, scale: float) -> void:
	if customer == null:
		return
	customer.patience_tick_scale = scale


func _despawn(npc: CustomerNpc) -> void:
	if npc.customer != null:
		_npcs.erase(npc.customer)
		_dwell_left.erase(npc.customer)
		_browse_queues.erase(npc.customer)
		_desk_ready.erase(npc.customer)
	npc.queue_free()


func _npc_list() -> Array[CustomerNpc]:
	var list: Array[CustomerNpc] = []
	for value: Variant in _npcs.values():
		var npc := value as CustomerNpc
		if npc != null and is_instance_valid(npc):
			list.append(npc)
	return list


func _find_spawner() -> Node:
	var systems := get_parent()
	if systems == null:
		if not is_inside_tree():
			return null
		return get_tree().get_first_node_in_group("customer_spawner")
	return systems.get_node_or_null("CustomerSpawner")


func _npc_point(npc: CustomerNpc) -> Vector3:
	if npc != null:
		return npc.position
	return _entrance


func _is_floor_phase() -> bool:
	var gs := _autoload("GameState")
	if gs == null:
		return false
	return int(gs.get("current_phase")) == DayPhasePolicy.FLOOR


func _autoload(node_name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null(node_name)


func _connect_bus(signal_name: String, callback: Callable) -> void:
	var bus := _autoload("EventBus")
	if bus == null:
		return
	if not bus.is_connected(signal_name, callback):
		bus.connect(signal_name, callback)


func _emit_bus(signal_name: String, args: Array) -> void:
	var bus := _autoload("EventBus")
	if bus == null:
		return
	match args.size():
		1:
			bus.emit_signal(signal_name, args[0])
		2:
			bus.emit_signal(signal_name, args[0], args[1])
		3:
			bus.emit_signal(signal_name, args[0], args[1], args[2])
		_:
			bus.emit_signal(signal_name)
