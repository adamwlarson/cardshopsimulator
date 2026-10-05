class_name BuylistFewerLotsPolicy
extends RefCounted

## BN1: open-day seller-lot / seller-walk-in starve for stingy buylist.
## Reads the player's sealed / singles NM / graded percents as AW1 stores
## them. Any category strictly below drip_floor (same floor BM1 uses) →
## apply fewer_lots_mult once to that day's seller (flipper) weight.
## Multiple low categories do not stack. High % does not raise traffic.
## Out: marketplace / auction / distributor lots, buyer door spawn, whale.
## Not a sell weight. Does not change BM1 settle −1.
const FEWER_LOTS_MULT := 0.50


static func fewer_lots_mult(configured: float = 0.0) -> float:
	if configured <= 0.0 or configured > 1.0:
		return FEWER_LOTS_MULT
	return configured


static func fewer_lots_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return FEWER_LOTS_MULT
	return fewer_lots_mult(config.buylist_fewer_lots_mult)


static func seller_weight_mult(
	pcts: Variant,
	config: BalanceConfig = null
) -> float:
	if BuylistDripPolicy.any_below_floor_for(pcts, config):
		return fewer_lots_mult_for(config)
	return 1.0


static func is_starved(
	pcts: Variant,
	config: BalanceConfig = null
) -> bool:
	return seller_weight_mult(pcts, config) < 1.0
