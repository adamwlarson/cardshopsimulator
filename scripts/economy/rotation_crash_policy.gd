class_name RotationCrashPolicy
extends RefCounted

## BS1: systems §8 Rotation / ban — staples crash. Soft leak
## (`soft_rotation_leak`) telegraphs; this event is the crash. Surprise
## catalog rolls use surprise_weight (missing → 0.5 vs default 1.0).
## While active, that set's staple singles read hidden market through a
## non-compounding event mult seeded once per event. Other non-bulk
## singles in the set get a milder mult. Bulk, sealed, accessories, and
## other sets stay out. AA-BASE never rotates. Does not rewrite listed
## prices or cash, buyer door spawn, whale weight, or AR1 drift.
## Missing / ≤0 duration → 5. Missing min → 0.45. Missing max → 0.70.
## Missing mild → 0.90. Min ≤ 0, max < min, max > 1, or mild ∉ (0, 1]
## fall back to those defaults. Not a sell weight. Soft catalog closed.
const DURATION_DAYS := 5
const SURPRISE_WEIGHT := 0.5
const MULT_MIN := 0.45
const MULT_MAX := 0.70
const MILD_MULT := 0.90
const BASE_SET_ID := &"AA-BASE"
const TAG_STAPLE := &"staple"
const TAG_BULK := &"bulk"


static func duration_days(configured: int = 0) -> int:
	if configured <= 0:
		return DURATION_DAYS
	return configured


static func duration_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return DURATION_DAYS
	return duration_days(config.rotation_crash_duration_days)


static func surprise_weight(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return SURPRISE_WEIGHT
	return configured


static func surprise_weight_for(config: BalanceConfig = null) -> float:
	if config == null:
		return SURPRISE_WEIGHT
	return surprise_weight(config.rotation_crash_surprise_weight)


static func crash_mult_min(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return MULT_MIN
	return configured


static func crash_mult_max(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return MULT_MAX
	return configured


static func crash_mult_band(
	configured_min: float = 0.0,
	configured_max: float = 0.0
) -> Vector2:
	var lo := crash_mult_min(configured_min)
	var hi := crash_mult_max(configured_max)
	if lo <= 0.0 or hi < lo or hi > 1.0:
		return Vector2(MULT_MIN, MULT_MAX)
	return Vector2(lo, hi)


static func crash_mult_band_for(config: BalanceConfig = null) -> Vector2:
	if config == null:
		return Vector2(MULT_MIN, MULT_MAX)
	return crash_mult_band(
		config.rotation_crash_mult_min,
		config.rotation_crash_mult_max
	)


static func mild_mult(configured: float = 0.0) -> float:
	if configured <= 0.0 or configured > 1.0:
		return MILD_MULT
	return configured


static func mild_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return MILD_MULT
	return mild_mult(config.rotation_mild_mult)


static func roll_crash_mult(rng: RandomNumberGenerator, config: BalanceConfig = null) -> float:
	var band := crash_mult_band_for(config)
	if rng == null:
		return band.x
	return rng.randf_range(band.x, band.y)


static func is_base_set(set_id: StringName) -> bool:
	return set_id == BASE_SET_ID


static func oldest_non_base_set(set_ids: Array) -> StringName:
	var names: PackedStringArray = []
	var seen := {}
	for value: Variant in set_ids:
		var set_id := StringName(value)
		if set_id.is_empty() or is_base_set(set_id):
			continue
		var key := String(set_id)
		if seen.has(key):
			continue
		seen[key] = true
		names.append(key)
	names.sort()
	if names.is_empty():
		return &""
	return StringName(names[0])


static func banner_text(set_display_name: String) -> String:
	var label := set_display_name.strip_edges()
	if label.is_empty():
		label = "format"
	return "Rotation: %s staples cooling" % label


static func sku_has_tag(sku: ProductSKU, tag: StringName) -> bool:
	if sku == null or tag.is_empty():
		return false
	return tag in sku.tags


static func is_set_single(sku: ProductSKU, set_id: StringName) -> bool:
	if sku == null or sku.product_class != ProductSKU.ProductClass.SINGLE:
		return false
	if set_id.is_empty() or sku.set_id != set_id:
		return false
	return true


static func market_mult_for_sku(
	sku: ProductSKU,
	set_id: StringName,
	crash_mult: float,
	mild: float
) -> float:
	if not is_set_single(sku, set_id):
		return 1.0
	if sku_has_tag(sku, TAG_BULK):
		return 1.0
	if sku_has_tag(sku, TAG_STAPLE):
		if crash_mult <= 0.0:
			return MULT_MIN
		return crash_mult
	return mild_mult(mild)
