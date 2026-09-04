class_name CustomerNpc
extends Node3D

const WALK_SPEED := 1.35

var customer: CustomerProfile
var floor_state: int = 0
var cast_slot: StringName = &"C1"
var body_height: float = 1.70
var body_color: Color = Color(0.34, 0.52, 0.56)
var walk_speed: float = WALK_SPEED
var path: Array[Vector3] = []
var icon: CustomerIntentIcon
var _body: MeshInstance3D
var _material: StandardMaterial3D


func configure(profile: CustomerProfile) -> void:
	customer = profile
	var visual: Dictionary = CustomerCast.visual_for(
		profile.archetype_id if profile != null else &"regular"
	)
	cast_slot = StringName(visual.get("slot", &"C1"))
	body_height = float(visual.get("height", 1.70))
	body_color = visual.get("color", Color(0.34, 0.52, 0.56))
	_build_visual(float(visual.get("radius", 0.22)))
	add_to_group("customer_npc")


func _build_visual(radius: float) -> void:
	_material = StandardMaterial3D.new()
	_material.albedo_color = body_color
	_material.roughness = 0.62
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = body_height
	_body = MeshInstance3D.new()
	_body.mesh = mesh
	_body.material_override = _material
	_body.position = Vector3(0.0, body_height * 0.5, 0.0)
	add_child(_body)
	icon = CustomerIntentIcon.new()
	icon.position = Vector3(0.0, body_height + 0.28, 0.0)
	add_child(icon)


func set_floor_state(next: int) -> void:
	floor_state = next


func set_intent(intent: CustomerIntentIcon.Intent) -> void:
	if icon == null:
		return
	icon.apply_intent(intent)


func set_highlighted(on: bool) -> void:
	if _material == null:
		return
	_material.emission_enabled = on
	_material.emission = body_color * 0.35 if on else Color.BLACK
	_material.emission_energy_multiplier = 0.8 if on else 0.0


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
		look_at(Vector3(target.x, position.y, target.z), Vector3.UP)


func icon_presentation() -> Dictionary:
	if icon == null:
		return {}
	return icon.presentation()
