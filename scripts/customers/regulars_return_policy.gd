class_name RegularsReturnPolicy
extends RefCounted

## systems §5.1 Regular / §5.3 band 50–74. Integer gate: Rep ≥ 50 can
## queue a next-floor Regular after a listed-price sale. Rep ≤ 49 cannot.
const UNLOCK_REP := 50
## One queued return. A second listed sale the same day does not add another.
const QUEUE_CAP := 1
## Existing Regular archetype. No new want table.
const ARCHETYPE_ID := &"regular"
## BY1: persist queued count + remembered relationship sku_id.
const SAVE_KEY := "regulars_return"
const QUEUED_SAVE_KEY := "queued"
const SKU_ID_SAVE_KEY := "sku_id"
## Budget used only to reuse the existing floor-offer lookup. Not a sell weight.
const FLOOR_LISTED_BUDGET_CENTS := 100_000_000


static func unlock_rep(configured: int = UNLOCK_REP) -> int:
	if configured <= 0:
		return UNLOCK_REP
	return configured


static func queue_cap(configured: int = QUEUE_CAP) -> int:
	if configured <= 0:
		return QUEUE_CAP
	return configured


static func is_unlocked(reputation: int, configured_unlock: int = UNLOCK_REP) -> bool:
	return reputation >= unlock_rep(configured_unlock)


static func can_queue(
	reputation: int,
	queued: int,
	configured_unlock: int = UNLOCK_REP,
	configured_cap: int = QUEUE_CAP
) -> bool:
	return (
		is_unlocked(reputation, configured_unlock)
		and queued < queue_cap(configured_cap)
	)


static func remembered_sku_from_customer(customer: CustomerProfile) -> StringName:
	if customer == null:
		return &""
	if not customer.target_sku.is_empty():
		return customer.target_sku
	if customer.desired_skus.is_empty():
		return &""
	return StringName(customer.desired_skus[0])


static func apply_relationship_stock(
	customer: CustomerProfile,
	sku_id: StringName
) -> void:
	if customer == null or sku_id.is_empty():
		return
	customer.wants_sku = sku_id
	customer.desired_skus = [sku_id]


static func is_live_catalog_sku(sku_id: StringName, catalog: Dictionary) -> bool:
	if sku_id.is_empty():
		return false
	return catalog.get(sku_id) is ProductSKU


static func can_apply_relationship_stock(
	sku_id: StringName,
	catalog: Dictionary,
	floor_listed: bool
) -> bool:
	return is_live_catalog_sku(sku_id, catalog) and floor_listed


static func to_save(queued: int, sku_id: StringName) -> Dictionary:
	var count := maxi(0, queued)
	var sku := "" if count <= 0 else String(sku_id)
	return {
		QUEUED_SAVE_KEY: count,
		SKU_ID_SAVE_KEY: sku,
	}


static func queued_from_save(value: Variant) -> int:
	if value is Dictionary:
		return maxi(0, int((value as Dictionary).get(QUEUED_SAVE_KEY, 0)))
	if value is int or value is float:
		return maxi(0, int(value))
	return 0


static func sku_id_from_save(value: Variant) -> StringName:
	if queued_from_save(value) <= 0:
		return &""
	if value is Dictionary:
		return StringName(String((value as Dictionary).get(SKU_ID_SAVE_KEY, "")))
	return &""
