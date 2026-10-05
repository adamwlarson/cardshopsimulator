class_name SetReleaseHypePolicy
extends RefCounted

## BQ1: systems §8 Set release hype — calendar-known sealed demand swing.
## Telegraph days ahead of the release window. While active, new-set sealed
## SKUs get hype_new_mult and old-set sealed SKUs get hype_old_mult.
## Accessories / singles / graded stay out. Does not rewrite listed prices
## or cash, buyer door spawn, whale weight, or wholesale (Supply glut).
## Missing / ≤0 telegraph → 3. Missing / ≤0 duration → 5 (inclusive of
## release day). Missing / ≤0 new → 1.40. Missing / ≤0 old → 0.70.
## Not a sell weight. Soft catalog closed.
const TELEGRAPH_DAYS := 3
const DURATION_DAYS := 5
const HYPE_NEW_MULT := 1.40
const HYPE_OLD_MULT := 0.70
const RELEASE_DAY_OF_MONTH := 4
const CYCLE_DAYS := 30
const CALENDAR_WEIGHT_MULT := 2.5


static func telegraph_days(configured: int = 0) -> int:
	if configured <= 0:
		return TELEGRAPH_DAYS
	return configured


static func telegraph_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return TELEGRAPH_DAYS
	return telegraph_days(config.set_release_telegraph_days)


static func duration_days(configured: int = 0) -> int:
	if configured <= 0:
		return DURATION_DAYS
	return configured


static func duration_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return DURATION_DAYS
	return duration_days(config.set_release_duration_days)


static func hype_new_mult(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return HYPE_NEW_MULT
	return configured


static func hype_new_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return HYPE_NEW_MULT
	return hype_new_mult(config.hype_new_mult)


static func hype_old_mult(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return HYPE_OLD_MULT
	return configured


static func hype_old_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return HYPE_OLD_MULT
	return hype_old_mult(config.hype_old_mult)


static func cycle_days_for(config: BalanceConfig = null) -> int:
	if config == null:
		return CYCLE_DAYS
	if config.month_length_days <= 0:
		return CYCLE_DAYS
	return config.month_length_days


static func day_of_cycle(day: int, config: BalanceConfig = null) -> int:
	var cycle := cycle_days_for(config)
	return posmod(day - 1, cycle) + 1


static func days_after_release(day: int, config: BalanceConfig = null) -> int:
	var cycle := cycle_days_for(config)
	return posmod(day_of_cycle(day, config) - RELEASE_DAY_OF_MONTH, cycle)


static func is_calendar_day(day: int, config: BalanceConfig = null) -> bool:
	return days_after_release(day, config) < duration_days_for(config)


static func is_telegraph_day(day: int, config: BalanceConfig = null) -> bool:
	if is_calendar_day(day, config):
		return false
	var until_next := cycle_days_for(config) - days_after_release(day, config)
	return until_next >= 1 and until_next <= telegraph_days_for(config)


static func remaining_days_on(day: int, config: BalanceConfig = null) -> int:
	if not is_calendar_day(day, config):
		return 0
	return duration_days_for(config) - days_after_release(day, config)


static func calendar_weight_mult(day: int, config: BalanceConfig = null) -> float:
	if is_calendar_day(day, config):
		return CALENDAR_WEIGHT_MULT
	return 0.0


static func demand_mult_for_sku(
	sku: ProductSKU,
	new_set_id: StringName,
	old_set_id: StringName,
	new_mult: float,
	old_mult: float
) -> float:
	if sku == null or sku.product_class != ProductSKU.ProductClass.SEALED:
		return 1.0
	if sku.set_id.is_empty():
		return 1.0
	if sku.set_id == new_set_id and not new_set_id.is_empty():
		return hype_new_mult(new_mult)
	if sku.set_id == old_set_id and not old_set_id.is_empty():
		return hype_old_mult(old_mult)
	return 1.0
