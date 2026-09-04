class_name CustomerNpc
extends Node3D

const WALK_SPEED := 1.35
# HOLD H6: 2× read scale so billboard icons stay readable from the locked
# behind-desk aisle HUD (−28° / FOV 70) without clipping the counter. Art disc
# is 0.32 m; authored GLB scale stays 1,1,1. No price/SKU on the bobber.
const ICON_HANG := -0.18
const ICON_READ_SCALE := 2.0
const CLIP_WALK := &"walk"
const CLIP_BROWSE_IDLE := &"browse_idle"

var customer: CustomerProfile
var floor_state: int = 0
var cast_slot: StringName = &"C1"
var body_height: float = 1.74
var body_color: Color = Color(0.34, 0.52, 0.56)
var body_scene_path: String = ""
var walk_speed: float = WALK_SPEED
var path: Array[Vector3] = []
var icon: CustomerIntentIcon
var _body_root: Node3D
var _material: StandardMaterial3D
var _highlight_meshes: Array[GeometryInstance3D] = []
var _anim: AnimationPlayer
var _active_clip: StringName = &""


func configure(profile: CustomerProfile) -> void:
	customer = profile
	var visual: Dictionary = CustomerCast.visual_for(
		profile.archetype_id if profile != null else &"regular"
	)
	cast_slot = StringName(visual.get("slot", &"C1"))
	body_height = float(visual.get("height", 1.74))
	body_color = visual.get("color", Color(0.34, 0.52, 0.56))
	body_scene_path = String(visual.get("scene", ""))
	_build_visual(float(visual.get("radius", 0.22)))
	add_to_group("customer_npc")


func _build_visual(radius: float) -> void:
	if not _try_instance_hero():
		_build_capsule_fallback(radius)
	_collect_highlight_meshes(_body_root)
	icon = CustomerIntentIcon.new()
	icon.position = Vector3(0.0, body_height + ICON_HANG, 0.0)
	icon.scale = Vector3.ONE * ICON_READ_SCALE
	add_child(icon)
	icon.ensure_built()


func _try_instance_hero() -> bool:
	if body_scene_path.is_empty() or not ResourceLoader.exists(body_scene_path):
		return false
	var packed := load(body_scene_path) as PackedScene
	if packed == null:
		return false
	var node := packed.instantiate() as Node3D
	if node == null:
		return false
	node.scale = Vector3.ONE
	node.position = Vector3.ZERO
	add_child(node)
	_body_root = node
	_bind_animation_player()
	return true


func _build_capsule_fallback(radius: float) -> void:
	_material = StandardMaterial3D.new()
	_material.albedo_color = body_color
	_material.roughness = 0.62
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = body_height
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.material_override = _material
	body.position = Vector3(0.0, body_height * 0.5, 0.0)
	add_child(body)
	_body_root = body


func set_floor_state(next: int) -> void:
	floor_state = next


func set_intent(intent: CustomerIntentIcon.Intent) -> void:
	if icon == null:
		return
	icon.apply_intent(intent)


func set_highlighted(on: bool) -> void:
	if _material != null:
		_material.emission_enabled = on
		_material.emission = body_color * 0.35 if on else Color.BLACK
		_material.emission_energy_multiplier = 0.8 if on else 0.0
	for mesh: GeometryInstance3D in _highlight_meshes:
		if mesh is MeshInstance3D:
			var inst := mesh as MeshInstance3D
			var surfaces := 1
			if inst.mesh != null:
				surfaces = inst.mesh.get_surface_count()
			for i: int in range(surfaces):
				var mat := inst.get_active_material(i)
				if not (mat is StandardMaterial3D):
					continue
				var std := mat as StandardMaterial3D
				if inst.get_surface_override_material(i) != std:
					std = std.duplicate() as StandardMaterial3D
					inst.set_surface_override_material(i, std)
				std.emission_enabled = on
				std.emission_energy_multiplier = 0.45 if on else 0.0


func follow_path(points: Array[Vector3]) -> void:
	path = points.duplicate()
	if not path.is_empty() and position.distance_to(path[0]) < 0.05:
		path.pop_front()
	_sync_locomotion_clip()


func is_moving() -> bool:
	return not path.is_empty()


func snap_to_path_end() -> void:
	if path.is_empty():
		_sync_locomotion_clip()
		return
	position = path.back()
	path.clear()
	_sync_locomotion_clip()


func tick_move(delta: float) -> void:
	if path.is_empty():
		_sync_locomotion_clip()
		return
	var target: Vector3 = path[0]
	target.y = 0.0
	var here := Vector3(position.x, 0.0, position.z)
	var offset := target - here
	var distance := offset.length()
	var step := walk_speed * delta
	if distance <= step:
		position = target
		path.pop_front()
		_sync_locomotion_clip()
		return
	var next := here + offset.normalized() * step
	position = next
	if distance > 0.02 and is_inside_tree():
		look_at(Vector3(target.x, position.y, target.z), Vector3.UP, true)
	_sync_locomotion_clip()


func current_locomotion_clip() -> StringName:
	return _active_clip


func has_locomotion_clips() -> bool:
	return (
		not _resolve_clip(CLIP_WALK).is_empty()
		and not _resolve_clip(CLIP_BROWSE_IDLE).is_empty()
	)


func body_root_local_position() -> Vector3:
	if _body_root == null:
		return Vector3.ZERO
	return _body_root.position


func icon_presentation() -> Dictionary:
	if icon == null:
		return {}
	return icon.presentation()


func _collect_highlight_meshes(root: Node) -> void:
	_highlight_meshes.clear()
	if root == null:
		return
	if root is GeometryInstance3D:
		_highlight_meshes.append(root as GeometryInstance3D)
	for child: Node in root.get_children():
		_collect_highlight_meshes(child)


func _bind_animation_player() -> void:
	_anim = _find_animation_player(_body_root)
	_play_locomotion_clip(CLIP_BROWSE_IDLE)


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


func _sync_locomotion_clip() -> void:
	if is_moving():
		_play_locomotion_clip(CLIP_WALK)
	else:
		_play_locomotion_clip(CLIP_BROWSE_IDLE)


func _play_locomotion_clip(clip: StringName) -> void:
	if _anim == null:
		return
	var resolved := _resolve_clip(clip)
	if resolved.is_empty():
		return
	if _active_clip == clip and _anim.is_playing():
		return
	var animation := _anim.get_animation(resolved)
	if animation != null and animation.loop_mode != Animation.LOOP_LINEAR:
		animation.loop_mode = Animation.LOOP_LINEAR
	_anim.play(resolved)
	_active_clip = clip


func _resolve_clip(clip: StringName) -> String:
	if _anim == null:
		return ""
	if _anim.has_animation(clip):
		return String(clip)
	var suffix := "/" + String(clip)
	for listed: String in _anim.get_animation_list():
		if listed == String(clip) or listed.ends_with(suffix):
			return listed
	return ""
