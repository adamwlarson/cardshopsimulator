class_name StaffPresenter
extends Node3D

## Thin floor visual for hired cashiers. One register station for MVP.
## No staff AI — idle_stand loop only. Does not touch camera or customer pathing.

const REGISTER_STATIONS := 1
const DEFAULT_STATION := Vector3(8.05, 0.0, -1.50)
const DEFAULT_YAW_DEGREES := -90.0
const CLIP_IDLE := StaffMember.CLIP_IDLE_STAND

var _slot: Node3D
var _clerks: Array[Node3D] = []
var _anims: Array[AnimationPlayer] = []
var _active_clip: StringName = &""


func _ready() -> void:
	_bind_slot()
	_connect_bus()
	sync_from_shop()


func sync_from_shop() -> void:
	_resize_clerks(_wanted_clerk_count())


func visible_clerk_count() -> int:
	var count := 0
	for clerk: Node3D in _clerks:
		if clerk != null and is_instance_valid(clerk) and clerk.visible:
			count += 1
	return count


func clerk_at(index: int) -> Node3D:
	if index < 0 or index >= _clerks.size():
		return null
	return _clerks[index]


func current_idle_clip() -> StringName:
	return _active_clip


func has_idle_loop() -> bool:
	if _anims.is_empty() or _anims[0] == null:
		return false
	var resolved := _resolve_clip(_anims[0], CLIP_IDLE)
	if resolved.is_empty():
		return false
	var animation := _anims[0].get_animation(resolved)
	return (
		animation != null
		and animation.loop_mode == Animation.LOOP_LINEAR
		and _anims[0].is_playing()
	)


func body_root_local_position() -> Vector3:
	if _clerks.is_empty() or _clerks[0] == null:
		return Vector3.ZERO
	if _clerks[0].get_child_count() == 0:
		return Vector3.ZERO
	var body := _clerks[0].get_child(0) as Node3D
	if body == null:
		return Vector3.ZERO
	return body.position


func _wanted_clerk_count() -> int:
	var shop := _shop()
	if shop == null:
		return 0
	return mini(shop.cashier_count(), mini(shop.staff_cap(), REGISTER_STATIONS))


func _resize_clerks(wanted: int) -> void:
	while _clerks.size() > wanted:
		var extra: Node3D = _clerks.pop_back()
		_anims.pop_back()
		if extra != null and is_instance_valid(extra):
			extra.queue_free()
	while _clerks.size() < wanted:
		var clerk := _spawn_clerk(_clerks.size())
		if clerk == null:
			break
		_clerks.append(clerk)
	if wanted == 0:
		_active_clip = &""


func _spawn_clerk(index: int) -> Node3D:
	var holder := Node3D.new()
	holder.name = "Cashier_%d" % (index + 1)
	holder.position = _station_position(index)
	holder.rotation_degrees = Vector3(0.0, _station_yaw_degrees(index), 0.0)
	add_child(holder)
	if not _try_instance_hero(holder):
		_build_capsule_fallback(holder)
	_play_idle(holder)
	return holder


func _try_instance_hero(holder: Node3D) -> bool:
	if not ResourceLoader.exists(StaffMember.SCENE_CASHIER):
		return false
	var packed := load(StaffMember.SCENE_CASHIER) as PackedScene
	if packed == null:
		return false
	var node := packed.instantiate() as Node3D
	if node == null:
		return false
	node.scale = Vector3.ONE
	node.position = Vector3.ZERO
	holder.add_child(node)
	return true


func _build_capsule_fallback(holder: Node3D) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.22, 0.40, 0.42)
	material.roughness = 0.62
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.22
	mesh.height = StaffMember.BODY_HEIGHT
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.material_override = material
	body.position = Vector3(0.0, StaffMember.BODY_HEIGHT * 0.5, 0.0)
	holder.add_child(body)


func _play_idle(holder: Node3D) -> void:
	var anim := _find_animation_player(holder)
	_anims.append(anim)
	if anim == null:
		return
	var resolved := _resolve_clip(anim, CLIP_IDLE)
	if resolved.is_empty():
		return
	var animation := anim.get_animation(resolved)
	if animation != null and animation.loop_mode != Animation.LOOP_LINEAR:
		animation.loop_mode = Animation.LOOP_LINEAR
	anim.play(resolved)
	_active_clip = CLIP_IDLE


func _find_animation_player(root: Node) -> AnimationPlayer:
	if root == null:
		return null
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child: Node in root.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _resolve_clip(anim: AnimationPlayer, clip: StringName) -> String:
	if anim == null:
		return ""
	if anim.has_animation(clip):
		return String(clip)
	var suffix := "/" + String(clip)
	for listed: String in anim.get_animation_list():
		if listed == String(clip) or listed.ends_with(suffix):
			return listed
	return ""


func _bind_slot() -> void:
	_slot = get_node_or_null("CashierSlot") as Node3D
	if _slot != null:
		return
	var shop := get_parent()
	if shop == null:
		return
	var staff_floor := shop.get_node_or_null("StaffFloor") as Node3D
	if staff_floor != null:
		_slot = staff_floor.get_node_or_null("CashierSlot") as Node3D


func _station_position(index: int) -> Vector3:
	if index == 0 and _slot != null:
		return _slot.position
	return DEFAULT_STATION + Vector3(0.0, 0.0, -0.7 * float(index))


func _station_yaw_degrees(index: int) -> float:
	if index == 0 and _slot != null:
		return _slot.rotation_degrees.y
	return DEFAULT_YAW_DEGREES


func _connect_bus() -> void:
	_connect_signal("staff_changed", _on_staff_changed)
	_connect_signal("shop_layout_changed", _on_staff_changed)
	_connect_signal("day_started", _on_day_started)
	_connect_signal("day_phase_changed", _on_phase_changed)


func _on_staff_changed() -> void:
	sync_from_shop()


func _on_day_started(_day: int) -> void:
	sync_from_shop()


func _on_phase_changed(_phase: int) -> void:
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
