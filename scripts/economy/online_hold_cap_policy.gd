class_name OnlineHoldCapPolicy
extends RefCounted

## BI1: reputation-gated soft cap on concurrent ONLINE_HOLD lots.
## One lot = one hold slot. Cancel or ship/fill frees a slot.
## Crossing a band mid-day raises the cap immediately. Dropping
## below never force-cancels existing holds. Out: in-shop stock,
## completed sales, fee ladder, cancel rules. Not a sell weight.
const CAP_LOW := 4
const CAP_MID := 8
const CAP_HIGH := 12
const MID_REP := 50
const HIGH_REP := 75
const MIN_CAP := 1


static func clamp_cap(cap: int) -> int:
	if cap <= 0:
		return MIN_CAP
	return cap


static func band_cap(configured: int, fallback: int) -> int:
	var resolved := configured if configured > 0 else fallback
	return clamp_cap(resolved)


static func low_cap(configured: int = 0) -> int:
	return band_cap(configured, CAP_LOW)


static func mid_cap(configured: int = 0) -> int:
	return band_cap(configured, CAP_MID)


static func high_cap(configured: int = 0) -> int:
	return band_cap(configured, CAP_HIGH)


static func cap_for(
	reputation: int,
	unlock_rep: int = 35,
	configured_low: int = 0,
	configured_mid: int = 0,
	configured_high: int = 0
) -> int:
	if reputation < unlock_rep:
		return 0
	if reputation >= HIGH_REP:
		return high_cap(configured_high)
	if reputation >= MID_REP:
		return mid_cap(configured_mid)
	return low_cap(configured_low)


static func cap_for_config(reputation: int, config: BalanceConfig = null) -> int:
	if config == null:
		return cap_for(reputation)
	return cap_for(
		reputation,
		config.online_unlock_rep,
		config.online_hold_cap_low,
		config.online_hold_cap_mid,
		config.online_hold_cap_high
	)


static func is_at_cap(hold_count: int, cap: int, unlocked: bool = true) -> bool:
	if not unlocked or cap <= 0:
		return false
	return hold_count >= cap
