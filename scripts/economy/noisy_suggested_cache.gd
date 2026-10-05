class_name NoisySuggestedCache
extends RefCounted

## BL1: live-SKU noisy suggested stickers for the current calendar day.
## Shop (in-shop PriceConfirm / BK1 listed sales) and online (list confirm)
## keep sibling caches. Position and move-feel are not stored here; they
## re-derive from the next §4.5 read after a clear. Not persisted.
## Out: list-time `suggested_at_list_cents` (BK1 Soft OK stays Soft).
var _shop_cents: Dictionary = {}
var _online_cents: Dictionary = {}


func shop_cents(sku_id: StringName) -> int:
	if sku_id.is_empty():
		return 0
	return int(_shop_cents.get(sku_id, 0))


func online_cents(sku_id: StringName) -> int:
	if sku_id.is_empty():
		return 0
	return int(_online_cents.get(sku_id, 0))


func remember_shop(sku_id: StringName, suggested_cents: int) -> void:
	if sku_id.is_empty() or suggested_cents <= 0:
		return
	_shop_cents[sku_id] = suggested_cents


func remember_online(sku_id: StringName, suggested_cents: int) -> void:
	if sku_id.is_empty() or suggested_cents <= 0:
		return
	_online_cents[sku_id] = suggested_cents


func clear() -> void:
	_shop_cents.clear()
	_online_cents.clear()


func is_empty() -> bool:
	return _shop_cents.is_empty() and _online_cents.is_empty()
