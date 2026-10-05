class_name BuylistFloodPolicy
extends RefCounted

## BO1: open-day seller-lot / seller-walk-in flood for generous buylist.
## Reads the player's sealed / singles NM / graded percents as AW1 stores
## them. Any category strictly above flood_ceiling, and none strictly
## below drip_floor (same floor BM1/BN1 use) → apply flood_lots_mult once
## to that day's seller (flipper) weight. Multiple high categories do not
## stack. If any category is below drip_floor, BN1 starve wins — this
## policy returns 1.0 and does not flood. Out: marketplace / auction /
## distributor lots, buyer door spawn, whale. Not a sell weight. Does
## not change BM1 settle −1 or BN1 ×0.50.
const FLOOD_CEILING := 0.70
const FLOOD_LOTS_MULT := 1.50


static func flood_ceiling(configured: float = 0.0) -> float:
	if configured <= 0.0 or configured >= 1.0:
		return FLOOD_CEILING
	return configured


static func flood_ceiling_for(config: BalanceConfig = null) -> float:
	if config == null:
		return FLOOD_CEILING
	return flood_ceiling(config.buylist_flood_ceiling)


static func flood_lots_mult(configured: float = 0.0) -> float:
	if configured <= 1.0 or configured > 3.0:
		return FLOOD_LOTS_MULT
	return configured


static func flood_lots_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return FLOOD_LOTS_MULT
	return flood_lots_mult(config.buylist_flood_lots_mult)


static func is_above_ceiling(pct: float, configured_ceiling: float = 0.0) -> bool:
	return pct > flood_ceiling(configured_ceiling)


static func any_above_ceiling(
	pcts: Variant,
	configured_ceiling: float = 0.0
) -> bool:
	if pcts == null:
		return false
	var ceiling := flood_ceiling(configured_ceiling)
	for category: StringName in BuylistDripPolicy.CATEGORIES:
		if float(pcts.pct_for(category)) > ceiling:
			return true
	return false


static func any_above_ceiling_for(
	pcts: Variant,
	config: BalanceConfig = null
) -> bool:
	return any_above_ceiling(pcts, flood_ceiling_for(config))


static func seller_weight_mult(
	pcts: Variant,
	config: BalanceConfig = null
) -> float:
	if BuylistDripPolicy.any_below_floor_for(pcts, config):
		return 1.0
	if any_above_ceiling_for(pcts, config):
		return flood_lots_mult_for(config)
	return 1.0


static func is_flooded(
	pcts: Variant,
	config: BalanceConfig = null
) -> bool:
	return seller_weight_mult(pcts, config) > 1.0
