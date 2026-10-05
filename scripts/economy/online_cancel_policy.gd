class_name OnlineCancelPolicy
extends RefCounted

## BG1: frequent cancel of an ONLINE_HOLD listing before fill (I1 cancel
## path). First cancel each calendar day is free. Each extra same-day
## cancel applies soft Rep −1 once. Out: completed online sales, in-shop
## pulls, list create, cash cancel fees. Not a sell weight.
const FREE_PER_DAY := 1
const REP_HIT := 1
## BH1: save payload for today's ONLINE_HOLD cancel counter. Listings stay
## off this snapshot. Missing / non-dict data loads as day 0 / count 0.
const SAVE_DAY_KEY := "cancel_day"
const SAVE_COUNT_KEY := "cancels_today"


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


static func snapshot(cancel_day: int, cancels_today: int) -> Dictionary:
	return {
		SAVE_DAY_KEY: cancel_day,
		SAVE_COUNT_KEY: maxi(0, cancels_today),
	}


static func cancel_day_from_save(data: Dictionary) -> int:
	return int(data.get(SAVE_DAY_KEY, 0))


static func cancels_today_from_save(data: Dictionary) -> int:
	return maxi(0, int(data.get(SAVE_COUNT_KEY, 0)))
