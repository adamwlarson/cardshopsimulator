class_name ShopCamera
extends Camera3D

## Named home poses. Art tunes the exported transforms; look logic stays pose-name based.
const POSE_AISLE := &"aisle"
const POSE_BEHIND_COUNTER := &"behind_counter"

## Art Lead SoT — aisle reset / alternate home (PR #12 locked).
const AISLE_POSITION := Vector3(4.5, 1.65, -1.8)
const AISLE_ROTATION_DEGREES := Vector3(-28.0, 0.0, 0.0)

## Art Lead SoT — behind-desk Day1 start. Clerk side of checkout ~(7.2, 0, -1.35), look −Z.
## Alt if register occludes (not shipped): Vector3(7.55, 1.6, -0.55), same rot/fov.
const BEHIND_COUNTER_POSITION := Vector3(7.2, 1.6, -0.65)
const BEHIND_COUNTER_ROTATION_DEGREES := Vector3(-18.0, 0.0, 0.0)

## Art Lead look clamps. FOV stays locked; this script owns look (HUD must not mutate it).
const PITCH_MIN_DEGREES := -40.0
const PITCH_MAX_DEGREES := 5.0
const YAW_MIN_DEGREES := -70.0
const YAW_MAX_DEGREES := 70.0
const HOME_FOV := 70.0
const MEDIUM_AISLE_OFFSET := Vector3(1.8, 0.15, -0.9)

@export var aisle_position: Vector3 = AISLE_POSITION
@export var aisle_rotation_degrees: Vector3 = AISLE_ROTATION_DEGREES
@export var behind_counter_position: Vector3 = BEHIND_COUNTER_POSITION
@export var behind_counter_rotation_degrees: Vector3 = BEHIND_COUNTER_ROTATION_DEGREES
@export var default_home_pose: StringName = POSE_BEHIND_COUNTER
@export_range(0.01, 1.0, 0.01) var look_sensitivity_degrees: float = 0.12

var _home_pose: StringName = POSE_BEHIND_COUNTER
var _yaw_offset_degrees: float = 0.0
var _pitch_offset_degrees: float = 0.0
var _looking: bool = false
var _extent_offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	fov = HOME_FOV
	_bind_shop_extent()
	apply_home_pose(default_home_pose)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_RIGHT:
			_set_looking(mouse.pressed)
			get_viewport().set_input_as_handled()
		elif mouse.button_index == MOUSE_BUTTON_MIDDLE and mouse.pressed:
			reset_to_aisle_home()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseMotion and _looking:
		var motion := event as InputEventMouseMotion
		apply_look_delta(motion.relative)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode != KEY_R and event.keycode != KEY_HOME:
			return
		if _gui_owns_text_input():
			return
		reset_to_aisle_home()
		get_viewport().set_input_as_handled()


func apply_home_pose(pose: StringName) -> void:
	if pose != POSE_AISLE and pose != POSE_BEHIND_COUNTER:
		pose = POSE_BEHIND_COUNTER
	_home_pose = pose
	_yaw_offset_degrees = 0.0
	_pitch_offset_degrees = 0.0
	position = _home_position()
	fov = HOME_FOV
	_apply_clamped_look()


func set_medium_extent(enabled: bool) -> void:
	_extent_offset = MEDIUM_AISLE_OFFSET if enabled else Vector3.ZERO
	if _home_pose == POSE_AISLE:
		apply_home_pose(POSE_AISLE)


func reset_to_aisle_home() -> void:
	_set_looking(false)
	apply_home_pose(POSE_AISLE)


func apply_look_delta(relative_pixels: Vector2) -> void:
	_yaw_offset_degrees -= relative_pixels.x * look_sensitivity_degrees
	_pitch_offset_degrees -= relative_pixels.y * look_sensitivity_degrees
	_apply_clamped_look()


func get_home_pose() -> StringName:
	return _home_pose


func is_looking() -> bool:
	return _looking


func _set_looking(pressed: bool) -> void:
	_looking = pressed
	if pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Snappy: keep yaw/pitch offset on RMB release. Reset (MMB / R / Home) snaps to aisle.


func _home_position() -> Vector3:
	if _home_pose == POSE_AISLE:
		return aisle_position + _extent_offset
	return behind_counter_position


func _home_rotation_degrees() -> Vector3:
	if _home_pose == POSE_AISLE:
		return aisle_rotation_degrees
	return behind_counter_rotation_degrees


func _apply_clamped_look() -> void:
	var home_rot := _home_rotation_degrees()
	var pitch := clampf(
		home_rot.x + _pitch_offset_degrees,
		PITCH_MIN_DEGREES,
		PITCH_MAX_DEGREES
	)
	var yaw := clampf(
		home_rot.y + _yaw_offset_degrees,
		YAW_MIN_DEGREES,
		YAW_MAX_DEGREES
	)
	_pitch_offset_degrees = pitch - home_rot.x
	_yaw_offset_degrees = yaw - home_rot.y
	rotation_degrees = Vector3(pitch, yaw, 0.0)
	fov = HOME_FOV


func _gui_owns_text_input() -> bool:
	var focus := get_viewport().gui_get_focus_owner()
	return focus is LineEdit or focus is TextEdit


func _bind_shop_extent() -> void:
	var bus := _event_bus()
	if bus != null and not bus.is_connected("shop_layout_changed", _on_shop_layout_changed):
		bus.connect("shop_layout_changed", _on_shop_layout_changed)
	_sync_extent_from_shop()


func _on_shop_layout_changed() -> void:
	_sync_extent_from_shop()
	if _home_pose == POSE_AISLE:
		apply_home_pose(POSE_AISLE)


func _sync_extent_from_shop() -> void:
	_extent_offset = Vector3.ZERO
	var gs := _game_state()
	if gs == null:
		return
	var shop := gs.get("shop") as ShopState
	if shop == null or shop.tier != ShopState.Tier.MEDIUM:
		return
	_extent_offset = MEDIUM_AISLE_OFFSET


func _event_bus() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("EventBus")


func _game_state() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("GameState")
