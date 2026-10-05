class_name BuylistDripPolicy
extends RefCounted

## BM1: close-settle reputation drip for stingy buylist % of market.
## Reads the player's sealed / singles NM / graded percents as AW1 stores
## them. Any category strictly below drip_floor → Rep −1 once that day.
## Multiple low categories do not stack. Out: fewer-lots spawn (BN1). Not a sell weight.
const DRIP_FLOOR := 0.40
const REP_HIT := 1
const CATEGORIES: Array[StringName] = [
	BuylistPolicy.CATEGORY_SEALED,
	BuylistPolicy.CATEGORY_SINGLES_NM,
	BuylistPolicy.CATEGORY_GRADED,
]


static func drip_floor(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return DRIP_FLOOR
	return configured


static func drip_floor_for(config: BalanceConfig = null) -> float:
	if config == null:
		return DRIP_FLOOR
	return drip_floor(config.buylist_drip_floor)


static func rep_delta_for(_config: BalanceConfig = null) -> int:
	return -REP_HIT


static func is_category(category: Variant) -> bool:
	var named := named_category(category)
	return (
		named == BuylistPolicy.CATEGORY_SEALED
		or named == BuylistPolicy.CATEGORY_SINGLES_NM
		or named == BuylistPolicy.CATEGORY_GRADED
	)


static func named_category(category: Variant) -> StringName:
	if typeof(category) == TYPE_INT:
		match category as ProductSKU.ProductClass:
			ProductSKU.ProductClass.SEALED:
				return BuylistPolicy.CATEGORY_SEALED
			ProductSKU.ProductClass.SINGLE:
				return BuylistPolicy.CATEGORY_SINGLES_NM
			ProductSKU.ProductClass.GRADED:
				return BuylistPolicy.CATEGORY_GRADED
			_:
				return &""
	var raw := String(category).to_lower().replace(" ", "_")
	raw = raw.replace("-", "_").replace("/", "_")
	match raw:
		"sealed":
			return BuylistPolicy.CATEGORY_SEALED
		"singles_nm", "single", "singles", "nm":
			return BuylistPolicy.CATEGORY_SINGLES_NM
		"graded", "slab":
			return BuylistPolicy.CATEGORY_GRADED
		_:
			return StringName(raw)


static func is_below_floor(pct: float, configured_floor: float = 0.0) -> bool:
	return pct < drip_floor(configured_floor)


static func any_below_floor(
	pcts: Variant,
	configured_floor: float = 0.0
) -> bool:
	if pcts == null:
		return false
	var floor := drip_floor(configured_floor)
	for category: StringName in CATEGORIES:
		if float(pcts.pct_for(category)) < floor:
			return true
	return false


static func any_below_floor_for(
	pcts: Variant,
	config: BalanceConfig = null
) -> bool:
	return any_below_floor(pcts, drip_floor_for(config))


static func settle_rep_delta(
	pcts: Variant,
	config: BalanceConfig = null
) -> int:
	if any_below_floor_for(pcts, config):
		return rep_delta_for(config)
	return 0
