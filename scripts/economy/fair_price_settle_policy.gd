class_name FairPriceSettlePolicy
extends RefCounted

## BK1: close-settle reputation ticks for fair vs overprice listed sales.
## Compare ask to the noisy suggested the player already sees for that SKU.
## Overprice (−) once/day skips fair (+) that day. Caps are once each per day.
## Out: walkouts, cancel, mismatch, Fire. Not a sell weight.
const FAIR_MULT := 1.10
const GOUGE_MULT := 1.25
const FAIR_REP_GAIN := 1
const GOUGE_REP_HIT := 1


static func fair_mult(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return FAIR_MULT
	return configured


static func fair_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return FAIR_MULT
	return fair_mult(config.fair_price_fair_mult)


static func gouge_mult(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return GOUGE_MULT
	return configured


static func gouge_mult_for(config: BalanceConfig = null) -> float:
	if config == null:
		return GOUGE_MULT
	return gouge_mult(config.fair_price_gouge_mult)


static func fair_rep_gain(configured: int = 0) -> int:
	if configured <= 0:
		return FAIR_REP_GAIN
	return configured


static func fair_rep_gain_for(config: BalanceConfig = null) -> int:
	if config == null:
		return FAIR_REP_GAIN
	return fair_rep_gain(config.fair_price_fair_rep_gain)


static func gouge_rep_hit(configured: int = 0) -> int:
	if configured <= 0:
		return GOUGE_REP_HIT
	return configured


static func gouge_rep_hit_for(config: BalanceConfig = null) -> int:
	if config == null:
		return GOUGE_REP_HIT
	return gouge_rep_hit(config.fair_price_gouge_rep_hit)


static func fair_rep_delta_for(config: BalanceConfig = null) -> int:
	return fair_rep_gain_for(config)


static func gouge_rep_delta_for(config: BalanceConfig = null) -> int:
	return -gouge_rep_hit_for(config)


static func is_fair(
	ask_cents: int,
	suggested_cents: int,
	configured_mult: float = 0.0
) -> bool:
	if ask_cents <= 0 or suggested_cents <= 0:
		return false
	return float(ask_cents) <= float(suggested_cents) * fair_mult(configured_mult)


static func is_fair_for(
	ask_cents: int,
	suggested_cents: int,
	config: BalanceConfig = null
) -> bool:
	return is_fair(ask_cents, suggested_cents, fair_mult_for(config))


static func is_gouge(
	ask_cents: int,
	suggested_cents: int,
	configured_mult: float = 0.0
) -> bool:
	if ask_cents <= 0 or suggested_cents <= 0:
		return false
	return float(ask_cents) >= float(suggested_cents) * gouge_mult(configured_mult)


static func is_gouge_for(
	ask_cents: int,
	suggested_cents: int,
	config: BalanceConfig = null
) -> bool:
	return is_gouge(ask_cents, suggested_cents, gouge_mult_for(config))


static func settle_rep_delta(
	had_fair: bool,
	had_gouge: bool,
	config: BalanceConfig = null
) -> int:
	if had_gouge:
		return gouge_rep_delta_for(config)
	if had_fair:
		return fair_rep_delta_for(config)
	return 0
