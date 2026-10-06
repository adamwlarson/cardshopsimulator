class_name AuctionSnipePolicy
extends RefCounted

## systems §3 auction snipes. Prep-only timed lot. Seeded flag can
## offer exactly one snipe. A live named settle event forces the
## flag on for that prep. Quiet days use the seeded flag alone.
## BW1: SKU is a seeded draw from live SEALED / non-bulk SINGLE.
const RUN_SEED := 20261003
const ATTENTION_COST := 10
const COMP_WIDTH := 0.12
const ASK_OFFSET_MIN := 0.05
const ASK_OFFSET_MAX := 0.16
const OFFER_PREFIX := "auction-snipe-day-"
const DEFAULT_SKU_ID := &"AA-DUST-ETB"
const OFFER_LABEL := "Auction snipe"
const CONDITION_CUE := "Photo only — inspect recommended"
const CONFIDENCE := &"medium"
const QTY := 1
const BULK_TAG := &"bulk"
const LANE_SKU := 3


static func attention_cost(configured: int = 0) -> int:
	if configured <= 0:
		return ATTENTION_COST
	return configured


static func comp_width(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return COMP_WIDTH
	return configured


static func offer_id(day: int) -> StringName:
	return StringName("%s%d" % [OFFER_PREFIX, maxi(1, day)])


static func is_snipe_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func flag_on(seed: int, day: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 0)
	return rng.randi() % 2 == 0


static func should_offer(seed: int, day: int, named_event_live: bool) -> bool:
	if named_event_live:
		return true
	return flag_on(seed, day)


static func is_snipe_sku(sku: ProductSKU) -> bool:
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
		if is_snipe_sku(sku):
			raw.append(String(sku.id))
	raw.sort()
	var ids: Array[StringName] = []
	for item: String in raw:
		ids.append(StringName(item))
	return ids


static func pick_sku_id(
	seed: int,
	day: int,
	pool: Array[StringName],
	catalog: Dictionary = {}
) -> StringName:
	var chosen := &""
	if not pool.is_empty():
		var shuffled := _shuffled(pool, seed, day)
		if not shuffled.is_empty():
			chosen = shuffled[0]
	if not chosen.is_empty() and (catalog.is_empty() or _catalog_has(catalog, chosen)):
		return chosen
	if _catalog_has(catalog, DEFAULT_SKU_ID):
		return DEFAULT_SKU_ID
	return &""


static func quantity_for(_sku: ProductSKU = null) -> int:
	return QTY


static func noisy_basis_cents(
	basis_cents: int,
	seed: int,
	day: int,
	configured_width: float = 0.0
) -> int:
	if basis_cents <= 0:
		return 0
	var width := comp_width(configured_width)
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 1)
	var noise := rng.randf_range(-width, width)
	return maxi(1, roundi(float(basis_cents) * (1.0 + noise)))


static func ask_cents(
	basis_cents: int,
	seed: int,
	day: int,
	configured_width: float = 0.0
) -> int:
	var noisy := noisy_basis_cents(basis_cents, seed, day, configured_width)
	if noisy <= 0:
		return 0
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 2)
	var over := rng.randf() >= 0.5
	var delta := rng.randf_range(ASK_OFFSET_MIN, ASK_OFFSET_MAX)
	var factor := 1.0 + delta if over else 1.0 - delta
	return maxi(1, roundi(float(noisy) * factor))


static func _catalog_has(catalog: Dictionary, sku_id: StringName) -> bool:
	if catalog.is_empty() or sku_id.is_empty():
		return false
	return catalog.has(sku_id)


static func _shuffled(pool: Array[StringName], seed: int, day: int) -> Array[StringName]:
	var ids: Array[StringName] = pool.duplicate()
	if ids.size() <= 1:
		return ids
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, LANE_SKU)
	for index: int in range(ids.size() - 1, 0, -1):
		var swap_at := rng.randi_range(0, index)
		var held := ids[index]
		ids[index] = ids[swap_at]
		ids[swap_at] = held
	return ids


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (int(seed) * 1664525) ^ (int(day) * 22695477) ^ (int(lane) * 1013904223)
	return mixed & 0x7fffffff
