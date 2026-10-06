class_name ShadyTrunkPolicy
extends RefCounted

## systems §3 shady trunk. Prep-only night lot. A seeded night flag
## can offer exactly one trunk. No flag → no trunk that night.
## Ask is 25% of the same live basis today's marketplace leads use.
## Report is Rep +2 once. Graded lots on this channel can be fake at 8%.
## BX1: SKU is a seeded draw from live non-bulk SINGLE, offered as a
## graded slab (shipped grader / grade). Never sealed, accessory, or bulk.
const RUN_SEED := 20261003
const ASK_RATE := 0.25
const REPORT_REP_GAIN := 2
const FAKE_SLAB_RATE := 0.08
const COMP_WIDTH := 0.22
const SPACE_REQUIRED := 2
const DEFAULT_GRADE := 10.0
const OFFER_PREFIX := "shady-trunk-day-"
const DEFAULT_SKU_ID := &"AA-SKIE-052"
const DEFAULT_GRADER := &"Prism"
const OFFER_LABEL := "Trunk lot"
const CONDITION_CUE := "Photo only — inspect strongly recommended"
const CONFIDENCE := &"low"
const QTY := 1
const BULK_TAG := &"bulk"
const LANE_SKU := 3


static func ask_rate(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return ASK_RATE
	return configured


static func report_rep_gain(configured: int = 0) -> int:
	if configured <= 0:
		return REPORT_REP_GAIN
	return configured


static func fake_slab_rate(configured: float = -1.0) -> float:
	if configured < 0.0:
		return FAKE_SLAB_RATE
	return configured


static func comp_width(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return COMP_WIDTH
	return configured


static func offer_id(day: int) -> StringName:
	return StringName("%s%d" % [OFFER_PREFIX, maxi(1, day)])


static func is_trunk_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func flag_on(seed: int, day: int) -> bool:
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, 0)
	return rng.randi() % 2 == 0


static func should_offer(seed: int, day: int) -> bool:
	return flag_on(seed, day)


static func is_trunk_sku(sku: ProductSKU) -> bool:
	if sku == null:
		return false
	if sku.product_class != ProductSKU.ProductClass.SINGLE:
		return false
	return not sku.tags.has(BULK_TAG)


static func pool_sku_ids(catalog: Dictionary) -> Array[StringName]:
	var raw: Array[String] = []
	for value: Variant in catalog.values():
		var sku := value as ProductSKU
		if is_trunk_sku(sku):
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


static func ask_cents(basis_cents: int, configured_rate: float = 0.0) -> int:
	if basis_cents <= 0:
		return 0
	return maxi(1, roundi(float(basis_cents) * ask_rate(configured_rate)))


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
	var mixed := (
		(int(seed) * 22695477)
		^ (int(day) * 1013904223)
		^ (int(lane) * 1664525)
		^ 0x5f3759df
	)
	return mixed & 0x7fffffff
