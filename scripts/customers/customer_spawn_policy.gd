class_name CustomerSpawnPolicy
extends RefCounted

const FLOOR_PHASE := 1
## systems §5.3 band 0–24. Integer gate: Rep ≤ 24 is quiet, Rep ≥ 25 is baseline.
const QUIET_FLOOR_MAX_REP := 24
const QUIET_FLOOR_COUNT_MULT := 0.5
## systems §5.3 band 25–49. Named gate only: today's spawn count and today's
## whale weight. No extra multiplier. Stay under 50 and it does not get better.
const MID_BAND_MIN_REP := 25
const MID_BAND_MAX_REP := 49
## systems §5.3 band 75–100. Integer gate: Rep ≥ 75 is high, Rep ≤ 74 is today's weight.
const HIGH_REP_MIN_REP := 75
const HIGH_REP_WHALE_WEIGHT_MULT := 1.5
## One customer per live timer roll. Quiet floor halves this (round down, floor 0).
const BASELINE_SPAWN_COUNT := 1


static func can_spawn(phase: int) -> bool:
	return phase == FLOOR_PHASE


static func is_quiet_floor(reputation: int) -> bool:
	return reputation <= QUIET_FLOOR_MAX_REP


static func is_mid_band(reputation: int) -> bool:
	return reputation >= MID_BAND_MIN_REP and reputation <= MID_BAND_MAX_REP


static func is_high_rep(reputation: int) -> bool:
	return reputation >= HIGH_REP_MIN_REP


## Spawn count for one roll. Rep is read here, not cached across rolls.
## Quiet floor (≤24) is ×0.5 versus the same baseline at Rep ≥ 25,
## rounded down, floor 0. AM1 mid-band (25–49) keeps today's count.
## 50–74 and high-rep do not change count. This is traffic, not a sell weight.
static func spawn_count(
	reputation: int,
	baseline_count: int = BASELINE_SPAWN_COUNT
) -> int:
	if baseline_count <= 0:
		return 0
	if is_quiet_floor(reputation):
		return int(floor(float(baseline_count) * QUIET_FLOOR_COUNT_MULT))
	return baseline_count


static func whales_allowed(reputation: int) -> bool:
	return not is_quiet_floor(reputation)


## AJ1: high-rep whale pack. Applied after Convention / play-table bumps.
## Quiet floor already zeroed the whale; this must not revive it.
## AM1 mid-band (25–49) and Rep 50–74 return 1.0 so today's weight
## (including bumps) is unchanged. No mid-band multiplier.
static func high_rep_whale_weight_mult(reputation: int) -> float:
	if not whales_allowed(reputation):
		return 1.0
	if is_high_rep(reputation):
		return HIGH_REP_WHALE_WEIGHT_MULT
	return 1.0

