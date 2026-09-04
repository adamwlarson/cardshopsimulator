class_name QaInstrumentationService
extends Node

signal event_emitted(event_name: StringName, payload: Dictionary)

var _enabled_override: int = -1
var _events: Array[Dictionary] = []
var _cash_start_by_day: Dictionary = {}


func is_enabled() -> bool:
	if _enabled_override >= 0:
		return _enabled_override == 1
	return (
		OS.is_debug_build()
		and bool(ProjectSettings.get_setting("debug/qa_instrumentation", false))
	)


func set_force_enabled(enabled: bool) -> void:
	_enabled_override = 1 if enabled else 0


func clear() -> void:
	_events.clear()
	_cash_start_by_day.clear()


func get_events() -> Array[Dictionary]:
	return _events.duplicate(true)


func begin_day(day: int, cash_start_cents: int) -> void:
	if is_enabled():
		_cash_start_by_day[day] = cash_start_cents


func end_day(day: int, cash_end_cents: int) -> void:
	if not is_enabled() or not _cash_start_by_day.has(day):
		return
	var cash_start: int = _cash_start_by_day[day]
	_emit(&"day_cash_delta", {
		"day": day,
		"cash_start": cash_start,
		"cash_end": cash_end_cents,
		"delta": cash_end_cents - cash_start,
	})
	_cash_start_by_day.erase(day)


func record_buy_confirm(
	sku_id: StringName,
	quantity: int,
	unit_cost_cents: int,
	expected_margin_cents: int
) -> void:
	_emit(&"buy_confirm", {
		"sku": String(sku_id),
		"qty": quantity,
		"unit_cost": unit_cost_cents,
		"expected_margin": expected_margin_cents,
	})


func record_beat_started(beat_id: StringName, day: int) -> void:
	_emit(&"beat_started", {
		"beat_id": String(beat_id),
		"day": day,
	})


func record_beat_completed(
	beat_id: StringName,
	day: int,
	outcome: StringName
) -> void:
	_emit(&"beat_completed", {
		"beat_id": String(beat_id),
		"day": day,
		"outcome": String(outcome),
	})


func record_demand_signal_shown(
	screen: StringName,
	signal_dto: Resource,
	true_market_cents: int,
	true_demand_band: StringName,
	listed_price_cents: int = -1
) -> void:
	if not is_enabled():
		return
	var payload := {
		"screen": String(screen),
		"sku_id": String(signal_dto.get("sku_id")),
		"shown_comp_low_cents": int(signal_dto.get("shown_comp_low_cents")),
		"shown_comp_high_cents": int(signal_dto.get("shown_comp_high_cents")),
		"true_market_cents": true_market_cents,
		"shown_demand_band": String(signal_dto.get("shown_demand_band")),
		"true_demand_band": String(true_demand_band),
		"confidence": String(signal_dto.get("confidence")),
	}
	if screen == &"price_confirm":
		payload["listed_price_cents"] = listed_price_cents
		payload["move_feel"] = String(signal_dto.get("move_feel"))
	_emit(&"demand_signal_shown", payload)


func record_research_applied(payload: Dictionary) -> void:
	if not is_enabled():
		return
	_emit(&"research_applied", payload)


func record_market_event_rolled(payload: Dictionary) -> void:
	if not is_enabled():
		return
	_emit(&"market_event_rolled", payload)


func record_rearrange_attempted(payload: Dictionary) -> void:
	if not is_enabled():
		return
	_emit(&"rearrange_attempted", payload)


func record_save_pre_write(serialized_save: PackedByteArray) -> void:
	if is_enabled():
		_emit(&"save_hash_pre_write", {"hash": _sha256(serialized_save)})


func record_save_post_load(serialized_save: PackedByteArray) -> void:
	if is_enabled():
		_emit(&"save_hash_post_load", {"hash": _sha256(serialized_save)})


func _sha256(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(bytes)
	return context.finish().hex_encode()


func _emit(event_name: StringName, payload: Dictionary) -> void:
	if not is_enabled():
		return
	var event := {"event": String(event_name), "payload": payload.duplicate(true)}
	_events.append(event)
	event_emitted.emit(event_name, payload)
	print("[qa] %s" % JSON.stringify(event))
