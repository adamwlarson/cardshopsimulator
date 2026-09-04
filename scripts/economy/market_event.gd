class_name MarketEvent
extends RefCounted

const KIND_HYPE := &"hype_spike"
const KIND_ROTATION := &"soft_rotation_leak"
const KIND_FOG := &"fog_day"

var id: StringName = &""
var kind: StringName = &""
var title: String = ""
var remaining_days: int = 0
var duration_days: int = 0
var sku_id: StringName = &""
var set_id: StringName = &""
var fog_flag: bool = false


func is_active() -> bool:
	return remaining_days > 0 and not kind.is_empty()


func to_save() -> Dictionary:
	return {
		"id": String(id),
		"kind": String(kind),
		"title": title,
		"remaining_days": remaining_days,
		"duration_days": duration_days,
		"sku_id": String(sku_id),
		"set_id": String(set_id),
		"fog_flag": fog_flag,
	}


static func from_save(data: Dictionary) -> MarketEvent:
	var event := MarketEvent.new()
	if data.is_empty():
		return event
	event.id = StringName(data.get("id", ""))
	event.kind = StringName(data.get("kind", ""))
	event.title = String(data.get("title", ""))
	event.remaining_days = int(data.get("remaining_days", 0))
	event.duration_days = int(data.get("duration_days", event.remaining_days))
	event.sku_id = StringName(data.get("sku_id", ""))
	event.set_id = StringName(data.get("set_id", ""))
	event.fog_flag = bool(data.get("fog_flag", event.kind == KIND_FOG))
	return event
