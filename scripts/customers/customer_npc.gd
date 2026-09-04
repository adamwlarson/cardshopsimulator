class_name CustomerNpc
extends Node3D

const WALK_SPEED := 1.35
# Art disc is 0.32 m. Holder is scaled so the bobber still reads under the
# locked aisle HUD (−28° / FOV 70); authored GLB scale stays 1,1,1.
const ICON_HANG := -0.18
const ICON_READ_SCALE := 2.0

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


func is_moving() -> bool:
	return not path.is_empty()


func snap_to_path_end() -> void:
	if path.is_empty():
		return
	position = path.back()
	path.clear()


func tick_move(delta: float) -> void:
	if path.is_empty():
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
		return
	var next := here + offset.normalized() * step
	position = next
	if distance > 0.02 and is_inside_tree():
		look_at(Vector3(target.x, position.y, target.z), Vector3.UP, true)


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
