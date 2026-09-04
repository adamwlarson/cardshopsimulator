class_name CustomerIntentIcon
extends Node3D

enum Intent {
	BROWSE,
	BUY,
	SELL,
}

const SCENE_BROWSE := (
	"res://assets/props/shop/fixtures/prop_icon_browse_01/"
	+ "prop_icon_browse_01.glb"
)
const SCENE_BUY := (
	"res://assets/props/shop/fixtures/prop_icon_buy_01/"
	+ "prop_icon_buy_01.glb"
)
const SCENE_SELL := (
	"res://assets/props/shop/fixtures/prop_icon_sell_01/"
	+ "prop_icon_sell_01.glb"
)

const COLOR_BROWSE := Color(0.82, 0.84, 0.86)
const COLOR_BUY := Color(0.22, 0.72, 0.68)
const COLOR_SELL := Color(0.92, 0.62, 0.22)

var intent: Intent = Intent.BROWSE
var _meshes: Dictionary = {}
var _built: bool = false


func _ready() -> void:
	ensure_built()
	apply_intent(intent)
	set_process(true)


func _process(_delta: float) -> void:
	if not is_inside_tree():
		return
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return
	var target := cam.global_position
	target.y = global_position.y
	if target.distance_squared_to(global_position) < 0.0001:
		return
	look_at(target, Vector3.UP, true)


func ensure_built() -> void:
	if _built:
		return
	_instance_icon(Intent.BROWSE, SCENE_BROWSE, COLOR_BROWSE)
	_instance_icon(Intent.BUY, SCENE_BUY, COLOR_BUY)
	_instance_icon(Intent.SELL, SCENE_SELL, COLOR_SELL)
	_built = true
	apply_intent(intent)


func apply_intent(next: Intent) -> void:
	intent = next
	for key: Variant in _meshes.keys():
		var node := _meshes[key] as Node3D
		if node != null:
			node.visible = int(key) == int(next)


func intent_name() -> StringName:
	match intent:
		Intent.BUY:
			return &"buy"
		Intent.SELL:
			return &"sell"
		_:
			return &"browse"


func presentation() -> Dictionary:
	return {"intent": intent_name()}


static func scene_path_for(which: Intent) -> String:
	match which:
		Intent.BUY:
			return SCENE_BUY
		Intent.SELL:
			return SCENE_SELL
		_:
			return SCENE_BROWSE


func has_truth_fields() -> bool:
	for key: Variant in presentation().keys():
		var field := String(key)
		if (
			field.contains("sku")
			or field.contains("price")
			or field.contains("comp")
			or field.contains("true_market")
			or field.contains("cert_valid")
		):
			return true
	return false


func _instance_icon(which: Intent, path: String, fallback_color: Color) -> void:
	var node := _load_art_icon(path)
	if node == null:
		node = _make_fallback_disc(fallback_color)
	node.visible = false
	node.scale = Vector3.ONE
	add_child(node)
	_add_backing_disc(node)
	_prepare_icon_materials(node)
	_meshes[which] = node
	if is_inside_tree():
		call_deferred("_prepare_icon_materials", node)


func _load_art_icon(path: String) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	return packed.instantiate() as Node3D


func _make_fallback_disc(color: Color) -> Node3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.16
	mesh.bottom_radius = 0.16
	mesh.height = 0.032
	mesh.radial_segments = 16
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.position = Vector3(0.0, 0.16, 0.0)
	body.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	body.material_override = mat
	return body


func _add_backing_disc(parent: Node3D) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.17
	mesh.bottom_radius = 0.17
	mesh.height = 0.012
	mesh.radial_segments = 20
	var body := MeshInstance3D.new()
	body.mesh = mesh
	body.position = Vector3(0.0, 0.16, -0.02)
	body.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(0.08, 0.08, 0.09, 1.0)
	body.material_override = mat
	parent.add_child(body)


func _prepare_icon_materials(root: Node) -> void:
	if root is MeshInstance3D:
		var inst := root as MeshInstance3D
		inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		inst.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		if inst.mesh != null:
			for i: int in range(inst.mesh.get_surface_count()):
				var surface: Material = inst.get_surface_override_material(i)
				if surface == null:
					surface = inst.get_active_material(i)
				if surface == null:
					surface = inst.mesh.surface_get_material(i)
				if not (surface is StandardMaterial3D):
					continue
				var copy := (surface as StandardMaterial3D).duplicate() as StandardMaterial3D
				copy.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				copy.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
				copy.cull_mode = BaseMaterial3D.CULL_DISABLED
				copy.metallic = 0.0
				inst.set_surface_override_material(i, copy)
	elif root is GeometryInstance3D:
		var geom := root as GeometryInstance3D
		geom.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		geom.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	for child: Node in root.get_children():
		_prepare_icon_materials(child)
