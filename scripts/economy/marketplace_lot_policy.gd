class_name MarketplaceLotPolicy
extends RefCounted

## BU1: systems §3 recurring marketplace lots 1–3/day.
## PREP lines from live SEALED + non-bulk SINGLE SKUs. Ask is a seeded
## 40–70% of the same live basis AQ1 / AT1 already read. A successful
## buy requires one fetch pick (drive-out or courier). Days 1–3 stay
## dark so the day-1 lot and the §10 #3 outing steal stay untouched.
## Not a sell weight. Soft catalog closed.
const RUN_SEED := 20261003
const FIRST_DAY := 4
const MIN_PER_DAY := 1
const MAX_PER_DAY := 3
const ASK_MIN := 0.40
const ASK_MAX := 0.70
const QTY_SEALED := 2
const QTY_SINGLE := 1
const SPACE_REQUIRED := 1
const OFFER_PREFIX := "marketplace-lot-d"
const OFFER_LABEL := "Marketplace lot"
const FETCH_DRIVE := &"drive_out"
const FETCH_COURIER := &"courier"
const COURIER_MEMO := "Marketplace courier fee"
const DRIVE_LABEL := "Drive out · Attention %d · miss 1–2 FLOOR hours"
const COURIER_LABEL := "Courier · %s"
const TOAST := "%d marketplace lots posted"
const LANE_COUNT := 0
const LANE_DRAW := 1
const LANE_ASK := 10
const BULK_TAG := &"bulk"


static func first_day(configured: int = 0) -> int:
	if configured <= 0:
		return FIRST_DAY
	return configured


static func first_day_for(config: BalanceConfig = null) -> int:
	if config == null:
		return FIRST_DAY
	return first_day(config.marketplace_lots_first_day)


static func min_per_day(configured: int = 0, configured_max: int = 0) -> int:
	var resolved_max := max_per_day(configured, configured_max)
	if configured <= 0 or configured_max < configured:
		return MIN_PER_DAY
	return mini(configured, resolved_max)


static func max_per_day(configured_min: int = 0, configured_max: int = 0) -> int:
	if configured_min <= 0 or configured_max < configured_min:
		return MAX_PER_DAY
	if configured_max <= 0:
		return MAX_PER_DAY
	return configured_max


static func min_per_day_for(config: BalanceConfig = null) -> int:
	if config == null:
		return MIN_PER_DAY
	return min_per_day(
		config.marketplace_lots_min_per_day,
		config.marketplace_lots_max_per_day
	)


static func max_per_day_for(config: BalanceConfig = null) -> int:
	if config == null:
		return MAX_PER_DAY
	return max_per_day(
		config.marketplace_lots_min_per_day,
		config.marketplace_lots_max_per_day
	)


static func ask_min(configured_min: float = 0.0, configured_max: float = 0.0) -> float:
	if _ask_band_invalid(configured_min, configured_max):
		return ASK_MIN
	return configured_min


static func ask_max(configured_min: float = 0.0, configured_max: float = 0.0) -> float:
	if _ask_band_invalid(configured_min, configured_max):
		return ASK_MAX
	return configured_max


static func ask_min_for(config: BalanceConfig = null) -> float:
	if config == null:
		return ASK_MIN
	return ask_min(config.marketplace_lot_ask_min, config.marketplace_lot_ask_max)


static func ask_max_for(config: BalanceConfig = null) -> float:
	if config == null:
		return ASK_MAX
	return ask_max(config.marketplace_lot_ask_min, config.marketplace_lot_ask_max)


static func _ask_band_invalid(configured_min: float, configured_max: float) -> bool:
	return (
		configured_min <= 0.0
		or configured_max < configured_min
		or configured_max > 1.0
	)


static func is_lot_day(day: int, config: BalanceConfig = null) -> bool:
	return day >= first_day_for(config)


static func is_lot_sku(sku: ProductSKU) -> bool:
	if sku == null:
		return false
	if sku.product_class == ProductSKU.ProductClass.SEALED:
		return true
	if sku.product_class != ProductSKU.ProductClass.SINGLE:
		return false
	return not sku.tags.has(BULK_TAG)


static func quantity_for(sku: ProductSKU) -> int:
	if sku != null and sku.product_class == ProductSKU.ProductClass.SEALED:
		return QTY_SEALED
	return QTY_SINGLE


static func pool_sku_ids(catalog: Dictionary) -> Array[StringName]:
	var raw: Array[String] = []
	for value: Variant in catalog.values():
		var sku := value as ProductSKU
		if is_lot_sku(sku):
			raw.append(String(sku.id))
	raw.sort()
	var ids: Array[StringName] = []
	for item: String in raw:
		ids.append(StringName(item))
	return ids


static func lot_count(
	seed: int,
	day: int,
	pool_size: int,
	config: BalanceConfig = null
) -> int:
	if not is_lot_day(day, config) or pool_size <= 0:
		return 0
	var lo := min_per_day_for(config)
	var hi := max_per_day_for(config)
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, LANE_COUNT)
	return mini(pool_size, rng.randi_range(lo, hi))


static func pick_sku_ids(
	seed: int,
	day: int,
	pool: Array[StringName],
	count: int
) -> Array[StringName]:
	var picked: Array[StringName] = []
	if count <= 0 or pool.is_empty():
		return picked
	var ids: Array[StringName] = pool.duplicate()
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, LANE_DRAW)
	for index: int in range(ids.size() - 1, 0, -1):
		var swap_at := rng.randi_range(0, index)
		var held := ids[index]
		ids[index] = ids[swap_at]
		ids[swap_at] = held
	var take := mini(count, ids.size())
	for index: int in take:
		picked.append(ids[index])
	return picked


static func ask_rate(
	seed: int,
	day: int,
	lot_index: int,
	config: BalanceConfig = null
) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = _mix(seed, day, LANE_ASK + maxi(1, lot_index))
	return rng.randf_range(ask_min_for(config), ask_max_for(config))


static func ask_cents(
	basis_cents: int,
	seed: int,
	day: int,
	lot_index: int,
	config: BalanceConfig = null
) -> int:
	if basis_cents <= 0:
		return 0
	return maxi(1, roundi(float(basis_cents) * ask_rate(seed, day, lot_index, config)))


static func offer_id(day: int, lot_index: int) -> StringName:
	return StringName("%s%d-%d" % [OFFER_PREFIX, maxi(1, day), maxi(1, lot_index)])


static func is_lot_id(opportunity_id: StringName) -> bool:
	return String(opportunity_id).begins_with(OFFER_PREFIX)


static func is_fetch(fetch_mode: StringName) -> bool:
	return fetch_mode == FETCH_DRIVE or fetch_mode == FETCH_COURIER


static func drive_attention(configured: int = 0) -> int:
	if configured <= 0:
		return 25
	return configured


static func drive_attention_for(config: BalanceConfig = null) -> int:
	if config == null:
		return 25
	return drive_attention(config.marketplace_outing_attention)


static func drive_skip_seconds(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return 34.0
	return configured


static func drive_skip_seconds_for(config: BalanceConfig = null) -> float:
	if config == null:
		return 34.0
	return drive_skip_seconds(config.marketplace_outing_floor_skip_seconds)


static func courier_fee_cents(configured: int = 0) -> int:
	if configured <= 0:
		return 3_500
	return configured


static func courier_fee_for(config: BalanceConfig = null) -> int:
	if config == null:
		return 3_500
	return courier_fee_cents(config.marketplace_courier_fee_cents)


static func can_cover_drive(attention_remaining: int, config: BalanceConfig = null) -> bool:
	return attention_remaining >= drive_attention_for(config)


static func can_cover_courier(
	cash_cents: int,
	lot_total_cents: int,
	config: BalanceConfig = null
) -> bool:
	if lot_total_cents <= 0:
		return false
	return cash_cents >= lot_total_cents + courier_fee_for(config)


static func drive_label(config: BalanceConfig = null) -> String:
	return DRIVE_LABEL % drive_attention_for(config)


static func courier_label(fee_text: String, config: BalanceConfig = null) -> String:
	if fee_text.strip_edges().is_empty():
		return COURIER_LABEL % "$35.00"
	return COURIER_LABEL % fee_text


static func toast_for(count: int) -> String:
	if count <= 0:
		return ""
	return TOAST % count


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 1664525)
		^ (int(day) * 22695477)
		^ (int(lane) * 1013904223)
		^ 0x4d41524b
	)
	return mixed & 0x7fffffff
