class_name OnlineCancelPolicy
extends RefCounted

## BG1: frequent cancel of an ONLINE_HOLD listing before fill (I1 cancel
## path). First cancel each calendar day is free. Each extra same-day
## cancel applies soft Rep −1 once. Out: completed online sales, in-shop
## pulls, list create, cash cancel fees. Not a sell weight.
const FREE_PER_DAY := 1
const REP_HIT := 1


static func free_per_day(configured: int = 0) -> int:
	if configured <= 0:
		return FREE_PER_DAY
	return configured


static func free_per_day_for(config: BalanceConfig = null) -> int:
	if config == null:
		return FREE_PER_DAY
	return free_per_day(config.online_cancel_free_per_day)


static func rep_hit(configured: int = 0) -> int:
	if configured <= 0:
		return REP_HIT
	return configured


static func rep_hit_for(config: BalanceConfig = null) -> int:
	if config == null:
		return REP_HIT
	return rep_hit(config.online_cancel_rep_hit)


static func rep_delta(configured_hit: int = 0) -> int:
	return -rep_hit(configured_hit)


static func rep_delta_for(config: BalanceConfig = null) -> int:
	return -rep_hit_for(config)


static func is_frequent(cancels_today: int, configured_free: int = 0) -> bool:
	return cancels_today > free_per_day(configured_free)


static func is_frequent_for(
	cancels_today: int,
	config: BalanceConfig = null
) -> bool:
	return is_frequent(cancels_today, free_per_day_for(config))
