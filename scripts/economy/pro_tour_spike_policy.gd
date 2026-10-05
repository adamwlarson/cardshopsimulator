class_name ProTourSpikePolicy
extends RefCounted

## BR1: systems §8 Pro tour / influencer spike — settle-rolled singles
## archetype swing. 1-day telegraph before the spike window. While active,
## tagged singles (and slabs that follow the card ref) read hidden
## market through a non-compounding event mult seeded once per event.
## Sealed / accessories stay out. Does not rewrite listed prices or cash,
## buyer door spawn, whale weight, or AR1 drift. Missing / ≤0 telegraph → 1.
## Missing / ≤0 duration → 2 (inclusive of spike day). Missing min → 1.30.
## Missing max → 1.80. Min ≤ 0 or max < min falls back to 1.30 / 1.80.
## Not a sell weight. Soft catalog closed.
const TELEGRAPH_DAYS := 1
const DURATION_DAYS := 2
const MULT_MIN := 1.30
const MULT_MAX := 1.80
const TAG_AGGRO := &"archetype:aggro"
const TAG_CONTROL := &"archetype:control"
const TAG_MID := &"archetype:mid"
const TAG_PREFIX := "archetype:"


static func telegraph_days(configured: int = 0) -> int:
	if configured <= 0:
		return TELEGRAPH_DAYS
	return configured


static func telegraph_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return TELEGRAPH_DAYS
	return telegraph_days(config.pro_tour_telegraph_days)


static func duration_days(configured: int = 0) -> int:
	if configured <= 0:
		return DURATION_DAYS
	return configured


static func duration_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return DURATION_DAYS
	return duration_days(config.pro_tour_duration_days)


static func remaining_days_at_roll(config: BalanceConfig = null) -> int:
	return telegraph_days_for(config) + duration_days_for(config)


static func is_telegraphing(remaining_days: int, duration_days_value: int) -> bool:
	var window := duration_days(duration_days_value)
	return remaining_days > window


static func is_spike_window(remaining_days: int, duration_days_value: int) -> bool:
	var window := duration_days(duration_days_value)
	return remaining_days > 0 and remaining_days <= window


static func mult_min(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return MULT_MIN
	return configured


static func mult_max(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return MULT_MAX
	return configured


static func mult_band(configured_min: float = 0.0, configured_max: float = 0.0) -> Vector2:
	var lo := mult_min(configured_min)
	var hi := mult_max(configured_max)
	if hi < lo:
		return Vector2(MULT_MIN, MULT_MAX)
	return Vector2(lo, hi)


static func mult_band_for(config: BalanceConfig = null) -> Vector2:
	if config == null:
		return Vector2(MULT_MIN, MULT_MAX)
	return mult_band(config.pro_tour_mult_min, config.pro_tour_mult_max)


static func roll_mult(rng: RandomNumberGenerator, config: BalanceConfig = null) -> float:
	var band := mult_band_for(config)
	if rng == null:
		return band.x
	return rng.randf_range(band.x, band.y)


static func is_archetype_tag(tag: StringName) -> bool:
	return tag == TAG_AGGRO or tag == TAG_CONTROL or tag == TAG_MID


static func archetype_label(tag: StringName) -> String:
	var raw := String(tag)
	if raw.begins_with(TAG_PREFIX):
		return raw.substr(TAG_PREFIX.length())
	return raw


static func banner_text(tag: StringName) -> String:
	var label := archetype_label(tag)
	if label.is_empty():
		label = "pro"
	return "Pro tour buzz: %s decks" % label


static func sku_has_tag(sku: ProductSKU, tag: StringName) -> bool:
	if sku == null or tag.is_empty():
		return false
	return tag in sku.tags


static func is_affected_sku(sku: ProductSKU, tag: StringName) -> bool:
	if sku == null or sku.product_class != ProductSKU.ProductClass.SINGLE:
		return false
	return sku_has_tag(sku, tag)


static func market_mult_for_sku(sku: ProductSKU, tag: StringName, mult: float) -> float:
	if not is_affected_sku(sku, tag):
		return 1.0
	if mult <= 0.0:
		return MULT_MIN
	return mult
