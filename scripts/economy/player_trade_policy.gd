class_name PlayerTradePolicy
extends RefCounted

## BV1: systems §3 / §5.3 recurring player-trade pool.
## Extends AN1's Rep ≥ 50 gate. One seeded in-kind pair per Prep day
## from owned live SEALED / non-bulk SINGLE → a different live SKU.
## Missing / bad unlock falls back to 50. Not a sell weight.
const UNLOCK_REP := 50
const RUN_SEED := 20261003
const GIVE_QTY := 1
const RECEIVE_QTY := 1
const OFFER_PREFIX := "player-trade-d"
const OFFER_LABEL := "Shop trade"
const COUNTERPARTY := "Another shop"
const SEALED_CONDITION := "Sealed · NM"
const SINGLE_CONDITION := "NM"
const TOAST := "A shop wants to trade"
const SAVE_KEY := "player_trade_closed_day"
const LANE_GIVE := 0
const LANE_RECEIVE := 1
const BULK_TAG := &"bulk"
## AN1 Dust→Skie stays one legal draw when both SKUs qualify.
const SEEDED_GIVE_SKU := &"AA-DUST-ETB"
const SEEDED_RECEIVE_SKU := &"AA-SKIE-ETB"
const SEEDED_CONDITION := SEALED_CONDITION
const SEEDED_COUNTERPARTY := COUNTERPARTY
const SEEDED_GIVE_QTY := GIVE_QTY
const SEEDED_RECEIVE_QTY := RECEIVE_QTY
const SEEDED_OFFER_ID := &"player-trade-seeded-dust-for-skie"


static func unlock_rep(configured: int = UNLOCK_REP) -> int:
	if configured <= 0:
		return UNLOCK_REP
	return configured


static func is_unlocked(reputation: int, configured_unlock: int = UNLOCK_REP) -> bool:
	return reputation >= unlock_rep(configured_unlock)


static func can_offer(reputation: int, configured_unlock: int = UNLOCK_REP) -> bool:
	return is_unlocked(reputation, configured_unlock)


static func offer_id(day: int) -> StringName:
	return StringName("%s%d" % [OFFER_PREFIX, maxi(1, day)])


static func is_trade_id(offer_id_value: StringName) -> bool:
	return String(offer_id_value).begins_with(OFFER_PREFIX)


static func is_trade_sku(sku: ProductSKU) -> bool:
	if sku == null:
		return false
	if sku.product_class == ProductSKU.ProductClass.SEALED:
		return true
	if sku.product_class != ProductSKU.ProductClass.SINGLE:
		return false
	return not sku.tags.has(BULK_TAG)


static func pool_sku_ids(catalog: Dictionary) -> Array[StringName]:
	var raw: Array[String] = []
	for value: Variant in catalog.values():
		var sku := value as ProductSKU
		if is_trade_sku(sku):
			raw.append(String(sku.id))
	raw.sort()
	var ids: Array[StringName] = []
	for item: String in raw:
		ids.append(StringName(item))
	return ids


static func pick_pair(
	seed: int,
	day: int,
	give_ids: Array[StringName],
	receive_ids: Array[StringName]
) -> Dictionary:
	if give_ids.is_empty() or receive_ids.is_empty():
		return {}
	var gives := _shuffled(give_ids, seed, day, LANE_GIVE)
	var recvs := _shuffled(receive_ids, seed, day, LANE_RECEIVE)
	for give_id: StringName in gives:
		for receive_id: StringName in recvs:
			if receive_id != give_id:
				return {
					"give_sku_id": give_id,
					"receive_sku_id": receive_id,
				}
	return {}


static func condition_for(sku: ProductSKU, card: CardInstance = null) -> String:
	if sku != null and sku.product_class == ProductSKU.ProductClass.SEALED:
		return SEALED_CONDITION
	if card != null:
		var names := CardInstance.Condition.keys()
		var index := clampi(int(card.condition), 0, names.size() - 1)
		return String(names[index])
	return SINGLE_CONDITION


static func toast_for(has_offer: bool) -> String:
	if not has_offer:
		return ""
	return TOAST


static func closed_day_from_save(value: Variant) -> int:
	if value is int or value is float:
		var day := int(value)
		if day >= 1:
			return day
	return -1


static func _shuffled(
	pool: Array[StringName],
	seed: int,
	day: int,
	lane: int
) -> Array[StringName]:
	var ids: Array[StringName] = pool.duplicate()
	if ids.size() <= 1:
		return ids
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, lane)
	for index: int in range(ids.size() - 1, 0, -1):
		var swap_at := rng.randi_range(0, index)
		var held := ids[index]
		ids[index] = ids[swap_at]
		ids[swap_at] = held
	return ids


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 1664525)
		^ (int(day) * 22695477)
		^ (int(lane) * 1013904223)
		^ 0x50545244
	)
	return mixed & 0x7fffffff
