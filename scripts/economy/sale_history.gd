class_name SaleHistory
extends RefCounted

## BZ1: most-recent completed in-shop sale per sku_id.
## Record + lookup live here. Buy-confirm reads the map; it is display
## only. Not a sell weight.
## In: listed or negotiated counter / case / binder / pull sales.
## Out: online fills, walkouts, refusals, buylist buys, trades,
## fire-sale dumps outside the sale path, refunds / mismatch refunds.
const SAVE_KEY := "sale_history"
const UNIT_PRICE_KEY := "unit_price_cents"
const DAY_KEY := "day"

var _by_sku: Dictionary = {}


func reset() -> void:
	_by_sku.clear()


func record(sku_id: StringName, unit_price_cents: int, day: int) -> bool:
	if sku_id.is_empty() or unit_price_cents <= 0 or day <= 0:
		return false
	_by_sku[sku_id] = {
		UNIT_PRICE_KEY: unit_price_cents,
		DAY_KEY: day,
	}
	return true


func lookup(sku_id: StringName) -> Dictionary:
	if sku_id.is_empty() or not _by_sku.has(sku_id):
		return {}
	var raw: Variant = _by_sku[sku_id]
	if not raw is Dictionary:
		return {}
	var data := raw as Dictionary
	var price := int(data.get(UNIT_PRICE_KEY, 0))
	var day := int(data.get(DAY_KEY, 0))
	if price <= 0 or day <= 0:
		return {}
	return {
		UNIT_PRICE_KEY: price,
		DAY_KEY: day,
	}


func has(sku_id: StringName) -> bool:
	return not lookup(sku_id).is_empty()


static func days_ago(today: int, day: int) -> int:
	return maxi(0, today - day)


static func days_ago_label(today: int, day: int) -> String:
	var elapsed := days_ago(today, day)
	if elapsed <= 0:
		return "today"
	if elapsed == 1:
		return "1 day ago"
	return "%d days ago" % elapsed


func snapshot() -> Dictionary:
	var out := {}
	for sku: Variant in _by_sku.keys():
		var entry := lookup(StringName(String(sku)))
		if entry.is_empty():
			continue
		out[String(sku)] = entry
	return out


func apply_save(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	for sku: Variant in data.keys():
		var raw: Variant = data[sku]
		if not raw is Dictionary:
			continue
		record(
			StringName(String(sku)),
			int((raw as Dictionary).get(UNIT_PRICE_KEY, 0)),
			int((raw as Dictionary).get(DAY_KEY, 0))
		)
